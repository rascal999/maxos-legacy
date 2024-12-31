# Desktop Environment Configuration
#
# This module handles desktop-specific configurations including:
# - Desktop environment (i3/gnome/kde/xfce)
# - Theme settings
# - Font configuration
# - Terminal preferences

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userConfig;
  types = import ./types.nix { inherit lib; };
in {
  config = mkIf (cfg != null && cfg.desktop.enable) {
    # Desktop environment
    services = {
      displayManager.defaultSession = lib.mkForce (
        if cfg.desktop.environment == "i3" then "none+i3"
        else if cfg.desktop.environment == "gnome" then "gnome"
        else if cfg.desktop.environment == "kde" then "plasma"
        else "xfce"
      );
      
      xserver = {
        enable = true;
        
        # Desktop manager configuration
        desktopManager = {
          gnome.enable = lib.mkForce (cfg.desktop.environment == "gnome");
          plasma5.enable = lib.mkForce (cfg.desktop.environment == "kde");
          xfce.enable = lib.mkForce (cfg.desktop.environment == "xfce");
        };

        # Window manager configuration
        windowManager.i3.enable = cfg.desktop.environment == "i3";

        # Display manager configuration
        displayManager.lightdm.enable = true;
      };
    };

    # Home Manager configuration
    home-manager.users.${cfg.identity.username} = { pkgs, ... }: {
      # GTK theme configuration
      gtk = {
        enable = true;
        theme = {
          name = cfg.desktop.theme.gtk.theme;
          package = pkgs.gnome-themes-extra;
        };
        iconTheme = {
          name = cfg.desktop.theme.gtk.iconTheme;
          package = pkgs.papirus-icon-theme;
        };
        gtk3.extraConfig = {
          gtk-cursor-theme-name = cfg.desktop.theme.cursor.theme;
          gtk-cursor-theme-size = cfg.desktop.theme.cursor.size;
        };
      };

      # Font configuration
      fonts.fontconfig.enable = true;
      
      # Font packages
      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono  # JetBrains Mono Nerd Font
        inter  # Interface font
      ];

      # Terminal configuration
      programs.${cfg.desktop.terminal.program} = {
        enable = true;
        settings = {
          window.opacity = cfg.desktop.terminal.opacity;
          font = {
            size = cfg.desktop.terminal.fontSize;
            normal.family = cfg.desktop.fonts.monospace;
          };
        };
      };

      # Desktop environment specific configurations
      xsession = mkIf (cfg.desktop.environment == "i3") {
        enable = true;
        windowManager.i3 = {
          enable = true;
          config = lib.mkForce {
            terminal = cfg.desktop.terminal.program;
            modifier = "Mod4";  # Windows key
          };
        };
      };

      # Environment variables
      home.sessionVariables = {
        # HiDPI settings
        GDK_SCALE = toString cfg.desktop.fonts.scaling;
        GDK_DPI_SCALE = toString (1.0 / cfg.desktop.fonts.scaling);
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      };
    };

    # System-wide font configuration
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
      ];
      fontconfig = {
        defaultFonts = {
          monospace = [ cfg.desktop.fonts.monospace ];
          sansSerif = [ cfg.desktop.fonts.interface ];
        };
      };
    };
  };
}
