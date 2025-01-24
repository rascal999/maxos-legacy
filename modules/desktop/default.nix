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
    xorg.xrandr
    pciutils  # Provides lspci command
    bc  # For floating point calculations in brightness control
    adwaita-icon-theme
    redshift  # For color temperature and brightness adjustment
    pkgs.chromium
  ];

  # Enable dconf for GTK settings
  programs.dconf.enable = true;
}
