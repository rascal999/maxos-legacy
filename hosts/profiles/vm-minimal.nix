{ config, pkgs, lib, ... }:

{
  # Ensure nixpkgs is properly configured
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [];
  };

  imports = [
    ../common/default.nix  # Basic system configuration
    ./desktop/i3.nix      # Keep i3 configuration
  ];

  # Disable unnecessary services
  disabledModules = [
    "services/security/hologram-agent.nix"
    "services/networking/tayga.nix"
    "services/networking/transmission.nix"
  ];

  # Configure all services
  services = lib.mkForce {
    # Disable power management
    thermald.enable = false;
    tlp.enable = false;
  };

  # Minimal userConfig
  userConfig = {
    identity = {
      username = "user";
      fullName = "Test User";
      email = "user@example.com";
    };
    auth = {
      hashedPassword = null;
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
      aliases = {};
    };
    desktop = {
      enable = true;
      environment = "i3";
      theme.name = "dark";
      theme.gtk = {
        theme = "Adwaita-dark";
        iconTheme = "Papirus-Dark";
      };
      theme.cursor = {
        theme = "Adwaita";
        size = 24;
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
      enable = false;
      git = {
        enable = false;
        userName = "Test User";
        userEmail = "user@example.com";
        signingKey = null;
        editor = "nvim";
      };
      containers = {
        enable = false;
        virtualisation = false;
      };
      languages = [];
      editors = [];
    };
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
    services = {};
    extraGroups = [];
    extraPackages = [];
    mounts = [];
    backup = {
      enable = false;
      locations = [];
    };
  };

  # Basic system packages
  environment.systemPackages = with pkgs; [
    # Basic utilities
    git
    vim
    curl
    wget
    htop
    
    # i3 essentials
    i3status-rust
    dmenu
    alacritty
    feh
    
    # Basic applications for testing
    firefox
  ];

  # Disable hardware-specific features
  hardware = {
    bluetooth.enable = lib.mkForce false;
    pulseaudio.enable = false;  # Using pipewire
  };

  # Development tools configuration
  programs = {
    ccache = {
      enable = lib.mkForce false;
      packageNames = lib.mkForce [];
    };
  };

  # Basic fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      fira-code
    ];
  };
}
