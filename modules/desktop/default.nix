{ config, lib, pkgs, ... }:

{
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

  # GTK configuration
  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "adwaita-dark";

  # GTK theme settings
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  # System-wide GTK settings
  programs.dconf.enable = true;
  
  # GTK configuration
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs.gnome; [
    epiphany    # Web browser
    totem       # Video player
    geary       # Email client
    seahorse    # Password manager
  ];

  # Force GTK applications to use dark theme
  programs.gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
