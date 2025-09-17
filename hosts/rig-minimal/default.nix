{ config, pkgs, lib, ... }:

{
  imports = [
    ./boot.nix
    ./users.nix
  ];

  # Minimal rig configuration for quick testing
  # Focus: LUKS encryption + i3 window manager + basic tools

  # User configuration
  maxos.user = {
    name = "user";
    homeDirectory = "/home/user";
  };

  # Disable secrets for minimal setup
  maxos.tools.restic.useSopsSecrets = false;

  # Enable minimal desktop environment
  maxos.tools = {
    # Core desktop
    i3.enable = true;
    alacritty.enable = true;
    
    # Basic tools for testing
    firefox.enable = true;
    git.enable = true;
    
    # System tools
    system-utilities.enable = true;
  };

  # Basic system services
  services = {
    xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      windowManager.i3.enable = true;
    };
    
    # Auto-login for testing
    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };
    
    # Network management
    networkmanager.enable = true;
    
    # SSH for remote access
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  # Basic networking
  networking = {
    hostName = "rig-minimal";
    firewall.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # System version
  system.stateVersion = "25.05";
}