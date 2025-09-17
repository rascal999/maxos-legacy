{ config, pkgs, lib, ... }:

{
  imports = [
    ./boot.nix
    ./users.nix
  ];

  # Ultra-minimal standalone NixOS configuration for rapid install script testing
  # No MaxOS modules - pure NixOS configuration

  # Basic networking
  networking = {
    hostName = "rig-minimal";
    firewall.enable = true;
    networkmanager.enable = true;
  };

  # Basic system services
  services = {
    # SSH for remote access
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    
    # Auto-login for testing - no password needed
    getty.autologinUser = "user";
  };

  # Minimal system packages - just essentials
  environment.systemPackages = with pkgs; [
    git      # For repository operations
    wget     # Basic networking
    curl     # Basic networking
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # System version
  system.stateVersion = "25.05";
}