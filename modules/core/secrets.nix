{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.secrets;
in {
  options.maxos.secrets = {
    enable = mkEnableOption "Secrets management with sops-nix";
    
    defaultSopsFile = mkOption {
      type = types.path;
      default = "${config.maxos.user.secretsDirectory}/secrets.yaml";
      description = "Default sops secrets file";
    };
    
    age = {
      keyFile = mkOption {
        type = types.str;
        default = "${config.maxos.user.homeDirectory}/.config/sops/age/keys.txt";
        description = "Path to age private key file";
      };
      
      generateKey = mkOption {
        type = types.bool;
        default = false;
        description = "Generate age key if it doesn't exist";
      };
    };
    
    gnupg = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable GPG-based encryption for secrets";
      };
      
      home = mkOption {
        type = types.str;
        default = "${config.maxos.user.homeDirectory}/.gnupg";
        description = "GPG home directory";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable sops-nix
    sops = {
      defaultSopsFile = cfg.defaultSopsFile;
      validateSopsFiles = false; # Allow missing files during initial setup
      
      age = {
        keyFile = cfg.age.keyFile;
        generateKey = cfg.age.generateKey;
      };
      
      gnupg = mkIf cfg.gnupg.enable {
        home = cfg.gnupg.home;
        sshKeyPaths = [];
      };
    };
    
    # Create necessary directories
    systemd.tmpfiles.rules = [
      "d ${dirOf cfg.age.keyFile} 0700 ${config.maxos.user.name} users -"
    ] ++ optionals cfg.gnupg.enable [
      "d ${cfg.gnupg.home} 0700 ${config.maxos.user.name} users -"
    ];
    
    # Install sops and age tools plus helper script
    environment.systemPackages = with pkgs; [
      sops
      age
      (writeScriptBin "maxos-secrets-init" ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail
        
        echo "MaxOS Secrets Management Setup"
        echo "=============================="
        
        # Create age key if it doesn't exist
        if [[ ! -f "${cfg.age.keyFile}" ]]; then
          echo "Generating age key..."
          mkdir -p "$(dirname "${cfg.age.keyFile}")"
          ${pkgs.age}/bin/age-keygen -o "${cfg.age.keyFile}"
          chmod 600 "${cfg.age.keyFile}"
          echo "Age key generated at: ${cfg.age.keyFile}"
          echo "Public key:"
          grep "public key:" "${cfg.age.keyFile}"
        else
          echo "Age key already exists at: ${cfg.age.keyFile}"
        fi
        
        # Create example secrets file if it doesn't exist
        if [[ ! -f "${cfg.defaultSopsFile}" ]]; then
          echo "Creating example secrets file..."
          mkdir -p "$(dirname "${cfg.defaultSopsFile}")"
          cat > "${cfg.defaultSopsFile}" << 'EOF'
# Example secrets file for MaxOS
# Edit with: sops ${cfg.defaultSopsFile}
        
example_secret: changeme
restic_password: ""
b2_access_key: ""
b2_secret_key: ""
EOF
          echo "Example secrets file created at: ${cfg.defaultSopsFile}"
          echo "Edit it with: sops ${cfg.defaultSopsFile}"
        else
          echo "Secrets file already exists at: ${cfg.defaultSopsFile}"
        fi
      '')
    ] ++ optionals cfg.gnupg.enable [
      gnupg
    ];
  };
}