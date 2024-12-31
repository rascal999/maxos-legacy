# Example User Configuration
#
# This is an example of how to configure a user in MaxOS.
# Copy this file and modify it according to your needs.

{ config, pkgs, ... }:

{
  # Enable the user configuration module
  userConfig = {
    # Basic Identity (Required)
    identity = {
      username = "alice";
      fullName = "Alice Smith";
      email = "alice@example.com";
    };

    # Authentication (Required)
    auth = {
      # Generate with: mkpasswd -m sha-512
      # Or use agenix for encrypted secrets
      hashedPassword = null;
      
      # Your SSH public keys (recommended)
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... alice@laptop"
      ];
    };

    # Keyboard Configuration (Required)
    keyboard = {
      layout = "us";
      variant = "dvorak";  # Optional: dvorak, colemak, etc.
      options = [
        "caps:escape"  # Map Caps Lock to Escape
      ];
    };

    # Shell Configuration
    shell = {
      default = "zsh";
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      aliases = {
        ll = "ls -la";
        ".." = "cd ..";
        "..." = "cd ../..";
        g = "git";
        k = "kubectl";
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
      # Add your preferred development tools
      languages = with pkgs; [
        python3
        nodejs
        go
        rustc
        cargo
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
      # Browsers
      firefox
      chromium

      # Communication
      slack
      discord
      signal-desktop

      # Media
      vlc
      spotify

      # Utils
      ripgrep
      fd
      bat
      eza
      fzf
      tmux
    ];

    # System Services
    services = {
      syncthing.enable = true;
      printing.enable = true;
    };

    # Network Mounts
    mounts = [
      {
        source = "nas.local:/media";
        target = "/mnt/media";
        type = "nfs";
        options = [ "auto" "nofail" "x-systemd.automount" ];
      }
    ];

    # Security Configuration
    security = {
      gpg = {
        enable = true;
      };
      yubikey = {
        enable = true;
        pam = true;
      };
      firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
        allowedUDPPorts = [];
      };
    };

    # Backup Configuration
    backup = {
      enable = true;
      locations = [
        {
          path = "/home/alice/Documents";
          destination = "/mnt/backup/documents";
          frequency = "daily";
          retention = "30d";
        }
        {
          path = "/home/alice/Projects";
          destination = "/mnt/backup/projects";
          frequency = "hourly";
          retention = "7d";
        }
      ];
    };
  };
}
