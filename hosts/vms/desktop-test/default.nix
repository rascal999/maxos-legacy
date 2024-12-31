{ config, pkgs, lib, ... }:

{
  imports = [
    ../../profiles/vm.nix             # VM-specific optimizations and hardware config
    ../../profiles/vm-minimal.nix     # Minimal desktop environment for testing
  ];

  # Override userConfig for testing
  userConfig = {
    identity = {
      username = "user";
      fullName = "Example User";
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
        size = 16;
        scaling = 1.0;
      };
      terminal = {
        program = "alacritty";
        opacity = 0.95;
        fontSize = 16;
      };
    };
    development = lib.mkForce {
      enable = true;
      git = {
        enable = true;
        userName = "Example User";
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
    extraGroups = [ "wheel" "networkmanager" "docker" "audio" "video" "input" ];
    extraPackages = with pkgs; [
      # Testing tools
      xorg.xev
      xorg.xwininfo
      glxinfo
      vulkan-tools
      
      # Demo applications
      libreoffice
      gimp
      firefox
    ];
    mounts = [];
    backup = {
      enable = false;
      locations = [];
    };
  };

  # VM-specific configuration
  networking = {
    hostName = "desktop-test";
  };

  # Override some desktop profile settings for VM
  services = {
    thermald.enable = lib.mkForce false;
    tlp.enable = lib.mkForce false;
  };

  # Disable hardware features not needed in VM
  hardware.bluetooth.enable = lib.mkForce false;

  # Ensure overlays are properly configured
  nixpkgs.overlays = [];

  # System state version
  system.stateVersion = "23.11";
}
