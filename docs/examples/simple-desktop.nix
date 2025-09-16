# Simple Desktop Configuration Example
# 
# This example shows a basic desktop configuration using MaxOS
# Copy to hosts/your-hostname/default.nix and customize as needed

{ config, pkgs, ... }:
{
  imports = [
    # Include your hardware configuration
    ./hardware-configuration.nix
  ];

  # Configure the primary user
  maxos.user = {
    name = "john";  # Change to your username
    # Other paths will be automatically derived from this
  };

  # Enable secrets management
  maxos.secrets.enable = true;

  # Enable desktop tool bundle with all desktop applications
  modules.toolBundles.desktop = {
    enable = true;
    enableAll = true;  # Enable all desktop tools
  };

  # Enable development tools selectively
  modules.toolBundles.development = {
    enable = true;
    git = true;
    nodejs = true;
    editors = true;
    containerization = true;
  };

  # Enable security tools
  modules.toolBundles.security = {
    enable = true;
    passwordManagement = true;
    scanners = true;
  };

  # Configure individual tools with custom settings
  modules.tools = {
    docker = {
      enable = true;
      liveRestore = false;
      enableExperimental = true;
    };
    
    restic = {
      enable = true;
      useSopsSecrets = true;
      schedule = "*-*-* 02:00:00";  # Daily backup at 2 AM
    };
    
    zsh = {
      enable = true;
    };
  };

  # Basic system configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
  };

  # Locale and time
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable X11 with GNOME
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "us";
  };

  # Enable printing
  services.printing.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = "25.05";
}