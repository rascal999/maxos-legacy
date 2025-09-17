{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.gtk-theme;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # GTK theme has no hard dependencies
  
in {
  options.maxos.tools.gtk-theme = {
    enable = mkEnableOption "GTK dark theme configuration";
    
    theme = mkOption {
      type = types.str;
      default = "Adwaita-dark";
      description = "GTK theme name";
    };
    
    iconTheme = mkOption {
      type = types.str;
      default = "Adwaita";
      description = "GTK icon theme name";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # Enable dconf system-wide for GTK theme support
    programs.dconf.enable = true;
    
    # Enable dbus for dconf
    services.dbus.enable = true;
    
    # Install theme packages
    environment.systemPackages = with pkgs; [
      gnome-themes-extra
      adwaita-icon-theme
      adwaita-qt
    ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "GTK theme configuration has no hard dependencies";
      }
    ];
  };
}