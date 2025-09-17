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

  # SSH for remote access only
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
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