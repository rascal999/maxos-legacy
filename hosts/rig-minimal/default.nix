{ config, pkgs, lib, ... }:

{
  imports = [
    ./boot.nix
    ./users.nix
  ];

  # Ultra-minimal rig configuration for rapid install script testing
  # Focus: LUKS encryption + console only + SSH access

  # User configuration
  maxos.user = {
    name = "user";
    homeDirectory = "/home/user";
  };

  # Disable all optional tools and services
  maxos.tools.restic.useSopsSecrets = false;

  # Basic system services - minimal set
  services = {
    # SSH for remote access only
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    
    # Network management
    networkmanager.enable = true;
  };

  # Basic networking
  networking = {
    hostName = "rig-minimal";
    firewall.enable = true;
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