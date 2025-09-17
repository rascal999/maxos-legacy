{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.restic;
in {
  options.maxos.tools.restic = {
    enable = mkEnableOption "restic backup configuration";
    
    bucketName = mkOption {
      type = types.str;
      default = "alm-backup";
      description = "S3 bucket name (Wasabi/Backblaze B2)";
    };
    
    hostSubdir = mkOption {
      type = types.str;
      default = "";
      description = "Subdirectory within the bucket for this host's backups (defaults to hostname if empty)";
    };
    
    repository = mkOption {
      type = types.str;
      default = "";
      description = "Path to the restic repository (automatically constructed if empty)";
    };
    
    useSopsSecrets = mkOption {
      type = types.bool;
      default = config.maxos.secrets.enable or false;
      description = "Use sops-managed secrets instead of plain files";
    };
    
    passwordFile = mkOption {
      type = types.str;
      default = if cfg.useSopsSecrets 
        then config.sops.secrets.restic_password.path or "${config.maxos.user.secretsDirectory}/environments/personal/.restic-password"
        else "${config.maxos.user.secretsDirectory}/environments/personal/.restic-password";
      description = "Path to the file containing the repository password";
    };
    
    awsAccessKeyFile = mkOption {
      type = types.str;
      default = if cfg.useSopsSecrets 
        then config.sops.secrets.b2_access_key.path or "${config.maxos.user.secretsDirectory}/environments/personal/.b2-access-key"
        else "${config.maxos.user.secretsDirectory}/environments/personal/.b2-access-key";
      description = "Path to the file containing the S3 access key (Backblaze B2 keyID)";
    };
    
    awsSecretKeyFile = mkOption {
      type = types.str;
      default = if cfg.useSopsSecrets 
        then config.sops.secrets.b2_secret_key.path or "${config.maxos.user.secretsDirectory}/environments/personal/.b2-secret-key"
        else "${config.maxos.user.secretsDirectory}/environments/personal/.b2-secret-key";
      description = "Path to the file containing the S3 secret key (Backblaze B2 applicationKey)";
    };
    
    s3Endpoint = mkOption {
      type = types.str;
      default = "s3.us-west-004.backblazeb2.com";
      description = "S3 endpoint for Backblaze B2 (adjust region as needed)";
    };
    
    paths = mkOption {
      type = types.listOf types.str;
      default = [ config.maxos.user.homeDirectory ];
      description = "Paths to back up";
    };
    
    excludes = mkOption {
      type = types.listOf types.str;
      default = [
        "*.tmp"
        "*.temp"
        "*/node_modules"
        "*/target"
        "*/.cache"
        "*/.local/share/Trash"
        "*/.thumbnails"
        "*/Downloads"
        "*/.docker"
        "*/.npm"
        "*/.cargo/registry"
        "*/.cargo/git"
        "*/go/pkg"
        "*/.rustup"
        "*/.gradle"
        "*/.m2"
        "*/.ivy2"
        "*/.sbt"
        "*/venv"
        "*/__pycache__"
        "*.pyc"
        "*.pyo"
        "*/.git"
        "*/.svn"
        "*/.hg"
        "*/lost+found"
        "${config.maxos.user.homeDirectory}/.local/share/Steam"
        "${config.maxos.user.homeDirectory}/.steam"
        "${config.maxos.user.homeDirectory}/.wine"
        "${config.maxos.user.homeDirectory}/.PlayOnLinux"
        "${config.maxos.user.homeDirectory}/VirtualBox VMs"
        "${config.maxos.user.homeDirectory}/.VirtualBox"
        "${config.maxos.user.homeDirectory}/.vagrant.d"
        "${config.maxos.user.homeDirectory}/.minikube"
        "${config.maxos.user.homeDirectory}/.kube/cache"
      ];
      description = "Patterns to exclude from backup";
    };
    
    pruneOpts = mkOption {
      type = types.str;
      default = "--keep-daily 7 --keep-weekly 4 --keep-monthly 6 --keep-yearly 2";
      description = "Options for the restic forget command";
    };
    
    schedule = mkOption {
      type = types.str;
      default = "*-*-* 13:00:00";
      description = "When to run the backup (systemd calendar format)";
    };
  };

  config = mkIf cfg.enable {
    # Configure sops secrets if enabled
    sops.secrets = mkIf cfg.useSopsSecrets {
      restic_password = {
        owner = config.maxos.user.name;
        mode = "0400";
      };
      b2_access_key = {
        owner = config.maxos.user.name;
        mode = "0400";
      };
      b2_secret_key = {
        owner = config.maxos.user.name;
        mode = "0400";
      };
    };
    
    environment.systemPackages = with pkgs; [
      restic
      rclone  # Often used with restic for remote repositories
    ];
    
    # Backup service
    systemd.services.restic-backup = {
      description = "Restic backup service";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.restic ];
      
      environment = let
        # Determine the actual repository path
        actualRepository = if cfg.repository != "" then cfg.repository else
          let
            # Use the provided hostSubdir or default to hostname
            subdir = if cfg.hostSubdir != "" then cfg.hostSubdir else config.networking.hostName;
          in
            "s3:${cfg.s3Endpoint}/${cfg.bucketName}/${subdir}";
      in {
        RESTIC_REPOSITORY = actualRepository;
        RESTIC_PASSWORD_FILE = cfg.passwordFile;
        # Use AWS environment variables for Backblaze B2 authentication
        AWS_ACCESS_KEY_ID_FILE = cfg.awsAccessKeyFile;
        AWS_SECRET_ACCESS_KEY_FILE = cfg.awsSecretKeyFile;
        # Set the S3 endpoint for Backblaze B2
        AWS_ENDPOINT = cfg.s3Endpoint;
      };
      
      script = ''
        # Load AWS credentials from files
        export AWS_ACCESS_KEY_ID=$(cat $AWS_ACCESS_KEY_ID_FILE)
        export AWS_SECRET_ACCESS_KEY=$(cat $AWS_SECRET_ACCESS_KEY_FILE)
        
        # Initialize repository if it doesn't exist
        if ! restic snapshots &>/dev/null; then
          echo "Initializing restic repository at $RESTIC_REPOSITORY"
          restic init
        fi
        
        # Run backup
        echo "Starting backup at $(date)"
        restic backup ${concatStringsSep " " (map (path: "\"${path}\"") cfg.paths)} \
          ${concatStringsSep " " (map (pattern: "--exclude=\"${pattern}\"") cfg.excludes)}
        
        # Prune old backups
        echo "Pruning old backups"
        restic forget --prune ${cfg.pruneOpts}
        
        echo "Backup completed at $(date)"
      '';
      
      serviceConfig = {
        Type = "oneshot";
        User = config.maxos.user.name;
        IOSchedulingClass = "idle";
        CPUSchedulingPolicy = "idle";
      };
    };
    
    # Timer to run backup on schedule
    systemd.timers.restic-backup = {
      description = "Timer for restic backup";
      wantedBy = [ "timers.target" ];
      
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "30m";  # Add some randomization to avoid all systems backing up at once
      };
    };
  };
}