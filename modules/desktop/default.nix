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
  services.xserver = {
    enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };
  };

  environment.systemPackages = with pkgs; [
    xorg.xrandr
    pciutils  # Provides lspci command
    bc  # For floating point calculations in brightness control
    gnome.adwaita-icon-theme
  ];

  # Enable dconf for GTK settings
  programs.dconf.enable = true;

  # Configure GTK theme
  home-manager.users.user = {
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.adwaita-icon-theme;
      };
    };
  };
}
