# Test VM User Configuration
{ config, pkgs, ... }:

{
  # Enable the user configuration module
  userConfig = {
    # Basic Identity (Required)
    identity = {
      username = "user";
      fullName = "Test User";
      email = "user@example.com";
    };

    # Authentication (Required)
    auth = {
      # Password is set via users.users.user.initialPassword in the VM config
      hashedPassword = null;
      
      # No SSH keys needed for VM testing
      sshKeys = [];
    };

    # Keyboard Configuration (Required)
    keyboard = {
      layout = "us";
      variant = "";
      options = [];
    };

    # Shell Configuration
    shell = {
      default = "zsh";
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      aliases = {
        ll = "ls -la";
        ".." = "cd ..";
      };
    };

    # Desktop Environment
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

    # Development Environment
    development = {
      enable = true;
      git = {
        enable = true;
        userName = config.userConfig.identity.fullName;
        userEmail = config.userConfig.identity.email;
        editor = "nvim";
      };
      containers = {
        enable = true;
        virtualisation = true;
      };
      # Basic development tools for testing
      languages = with pkgs; [
        python3
        nodejs
      ];
      editors = with pkgs; [
        vscode
        neovim
      ];
    };

    # Additional Groups
    extraGroups = [
      "docker"
      "libvirtd"
    ];

    # Additional Packages
    extraPackages = with pkgs; [
      # Already included in VM config:
      # firefox
      # vlc
      # vscode
      
      # Additional testing utilities
      htop
      ripgrep
      fd
      bat
    ];

    # System Services
    services = {
      # Minimal services for testing
      printing.enable = true;
    };

    # Security Configuration
    security = {
      gpg.enable = false;
      yubikey = {
        enable = false;
        pam = false;
      };
      firewall = {
        enable = true;
        allowedTCPPorts = [];
        allowedUDPPorts = [];
      };
    };

    # Backup Configuration
    backup = {
      enable = false;
    };
  };
}
