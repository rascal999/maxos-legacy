# System Configuration
#
# This module handles core system configurations including:
# - User account setup
# - Group memberships
# - Network mounts
# - Backup configuration
# - System services

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userConfig;
  types = import ./types.nix { inherit lib; };
in {
  config = mkIf (cfg != null) {
    # User account configuration
    users = {
      mutableUsers = false;  # Don't allow user modification outside of Nix
      users.${cfg.identity.username} = {
        isNormalUser = true;
        description = cfg.identity.fullName;
        hashedPassword = cfg.auth.hashedPassword;
        shell = pkgs.${cfg.shell.default};
        
        # SSH keys for remote access
        openssh.authorizedKeys.keys = cfg.auth.sshKeys;
        
        # Groups
        extraGroups = [
          "wheel"           # sudo access
          "networkmanager"  # network management
          "audio"           # audio devices
          "video"          # video devices
          "input"          # input devices
        ] ++ cfg.extraGroups;
        
        # User packages
        packages = cfg.extraPackages;
      };
    };

    # Network mounts
    fileSystems = builtins.listToAttrs (map (mount: {
      name = mount.target;
      value = {
        device = mount.source;
        fsType = mount.type;
        options = mount.options;
      };
    }) cfg.mounts);

    # Shell configuration
    programs.${cfg.shell.default} = {
      enable = true;
      enableCompletion = cfg.shell.enableCompletion;
      
      # Global shell aliases
      shellAliases = cfg.shell.aliases;
    };

    # Keyboard configuration
    console.keyMap = cfg.keyboard.layout;

    # Services configuration
    services = mkMerge [
      # X server configuration
      {
        xserver = {
          xkb = {
            layout = cfg.keyboard.layout;
            variant = cfg.keyboard.variant;
            options = concatStringsSep "," cfg.keyboard.options;
          };
        };
      }

      # Backup service
      (mkIf cfg.backup.enable {
        borgbackup.jobs = builtins.listToAttrs (map (location: {
          name = builtins.replaceStrings ["/"] ["-"] location.path;
          value = {
            paths = [ location.path ];
            repo = location.destination;
            encryption = {
              mode = "repokey";
              passCommand = "cat /run/secrets/borgbackup-passphrase";
            };
            compression = "auto,lz4";
            startAt = location.frequency;
            prune.keep = {
              within = location.retention;
              daily = 7;
              weekly = 4;
              monthly = 6;
            };
            environment = {
              BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
              BORG_RSH = "ssh -i /run/secrets/borgbackup-ssh-key";
            };
          };
        }) cfg.backup.locations);
      })
      
      # User-defined services
      (mkIf (cfg.services != {}) cfg.services)
    ];

    # Home Manager configuration
    home-manager.users.${cfg.identity.username} = { pkgs, ... }: {
      # XDG Base Directory specification
      xdg = {
        enable = true;
        configHome = "${config.users.users.${cfg.identity.username}.home}/.config";
        cacheHome = "${config.users.users.${cfg.identity.username}.home}/.cache";
        dataHome = "${config.users.users.${cfg.identity.username}.home}/.local/share";
        stateHome = "${config.users.users.${cfg.identity.username}.home}/.local/state";
      };

      # Basic environment variables
      home.sessionVariables = {
        # XDG paths
        XDG_CONFIG_HOME = config.home-manager.users.${cfg.identity.username}.xdg.configHome;
        XDG_CACHE_HOME = config.home-manager.users.${cfg.identity.username}.xdg.cacheHome;
        XDG_DATA_HOME = config.home-manager.users.${cfg.identity.username}.xdg.dataHome;
        XDG_STATE_HOME = config.home-manager.users.${cfg.identity.username}.xdg.stateHome;
      };

      # Shell configuration
      programs.${cfg.shell.default} = {
        enable = true;
        enableCompletion = cfg.shell.enableCompletion;
        syntaxHighlighting.enable = cfg.shell.enableSyntaxHighlighting;
        shellAliases = lib.mkForce cfg.shell.aliases;
      };

      # Basic user packages
      home.packages = with pkgs; [
        # System tools
        htop
        btop
        ripgrep
        fd
        tree
        jq
        yq
        
        # Archive tools
        zip
        unzip
        p7zip
        
        # Network tools
        curl
        wget
        whois
        dig
        
        # Misc utilities
        bat       # Better cat
        eza       # Better ls
        du-dust   # Better du
        duf       # Better df
      ];
    };
  };
}
