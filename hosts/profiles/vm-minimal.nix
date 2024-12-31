{ config, pkgs, lib, ... }:

{
  imports = [
    ./desktop/i3.nix  # Keep i3 configuration
  ];

  # Basic X server configuration
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
  };

  # Basic audio configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
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

  # Disable power management
  services = {
    thermald.enable = lib.mkForce false;
    tlp.enable = lib.mkForce false;
  };

  # Ensure no development tools are enabled by default
  programs.ccache.enable = lib.mkForce false;

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
