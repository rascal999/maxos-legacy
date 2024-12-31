{ config, pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    ./users.nix
    ../../users/default.nix  # Import all user configurations
  ];

  # Default user configuration
  userConfig = {
    identity = {
      username = "user";
      fullName = "Default User";
      email = "user@localhost";
    };

    auth = {
      hashedPassword = "$6$rounds=1000000$L7Voce9TQrGZF8Yq$PK3wPNgJUh4Li3OCjwEQ7ejYBGX7gcgwUr.GHNk2EcIJKp7ea3p8Ch0/R.qjHRVQZXDKtHEHANzHGhV58FaB//";  # Password: "nixos"
      sshKeys = [];
    };

    keyboard = {
      layout = "us";
      variant = "";
      options = [];
    };

    shell = {
      default = "zsh";
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      aliases = {
        ll = "ls -la";
        ".." = "cd ..";
      };
    };

    desktop = {
      enable = true;
      environment = "i3";
      theme = {
        name = "dark";
        gtk = {
          theme = "Adwaita-dark";
          iconTheme = "Papirus-Dark";
        };
        cursor = {
          theme = "Adwaita";
          size = 24;
        };
      };
      fonts = {
        monospace = "JetBrains Mono";
        interface = "Inter";
        size = 11;
        scaling = 1.0;
      };
      terminal = {
        program = "alacritty";
        opacity = 0.95;
        fontSize = 12;
      };
    };

    development = {
      enable = true;
      git = {
        enable = true;
        userName = config.userConfig.identity.fullName;
        userEmail = config.userConfig.identity.email;
        editor = "vim";
      };
      containers.enable = false;
      languages = with pkgs; [ python3 nodejs ];
      editors = with pkgs; [ vim vscode ];
    };

    security = {
      gpg.enable = false;
      yubikey = {
        enable = false;
        pam = true;
      };
      firewall = {
        enable = true;
        allowedTCPPorts = [];
        allowedUDPPorts = [];
      };
    };

    extraGroups = [];
    extraPackages = [];
    services = {};
    mounts = [];
    backup.enable = false;
  };

  # Enable zsh since it's used as the default shell
  programs.zsh.enable = true;

  # Basic system configuration shared across all hosts
  boot = {
    tmp.cleanOnBoot = true;
    readOnlyNixStore = true;
  };
  
  # System-wide packages
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    htop
  ];

  # Basic networking configuration
  networking = {
    useDHCP = false;
    firewall.enable = true;
  };

  # Basic security settings
  security = {
    sudo.enable = true;
    # Enable PAM
    pam.sshAgentAuth.enable = true;
  };

  # System-wide SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Default locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Time zone
  time.timeZone = "UTC";

  # System features
  system.stateVersion = "23.11"; # Set appropriate version

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
