{ config, lib, pkgs, ... }:

{
  imports = [
    ../tools/keepassxc.nix
  ];

  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # X server configuration
  services.xserver.enable = true;

  # Display manager configuration
  services.displayManager.autoLogin = {
    enable = true;
    user = "user";
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    bc  # For floating point calculations in brightness control
    maim
    pciutils  # Provides lspci command
    redshift  # For color temperature and brightness adjustment
    scrot
    xdotool
    xorg.xrandr
    pkgs.chromium
    pkgs.python3
    pkgs.xclip
  ];

  # Enable dconf for GTK settings
  programs.dconf.enable = true;
}
