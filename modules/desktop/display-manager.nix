{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.desktop.displayManager;
in
{
  options.maxos.desktop.displayManager = {
    enable = mkEnableOption "display manager configuration";
    
    manager = mkOption {
      type = types.enum [ "lightdm" "gdm" "sddm" ];
      default = "lightdm";
      description = "Which display manager to use";
    };
    
    desktopEnvironment = mkOption {
      type = types.enum [ "xfce" "gnome" "kde" "i3" "none" ];
      default = "xfce";
      description = "Which desktop environment to enable";
    };
    
    theme = mkOption {
      type = types.str;
      default = "default";
      description = "Theme for the display manager";
    };
    
    autoLogin = {
      enable = mkEnableOption "auto login";
      user = mkOption {
        type = types.str;
        default = "";
        description = "User to auto-login as";
      };
    };
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      
      # Display Manager configuration
      displayManager = mkMerge [
        (mkIf (cfg.manager == "lightdm") {
          lightdm = {
            enable = true;
            greeters.gtk = {
              theme.name = mkIf (cfg.theme != "default") cfg.theme;
            };
          };
          autoLogin = mkIf cfg.autoLogin.enable {
            enable = true;
            user = cfg.autoLogin.user;
          };
        })
        
        (mkIf (cfg.manager == "gdm") {
          gdm = {
            enable = true;
            autoLogin = mkIf cfg.autoLogin.enable {
              enable = true;
              user = cfg.autoLogin.user;
            };
          };
        })
        
        (mkIf (cfg.manager == "sddm") {
          sddm = {
            enable = true;
            theme = mkIf (cfg.theme != "default") cfg.theme;
            autoLogin = mkIf cfg.autoLogin.enable {
              enable = true;
              user = cfg.autoLogin.user;
            };
          };
        })
      ];
      
      # Desktop Environment configuration
      desktopManager = mkMerge [
        (mkIf (cfg.desktopEnvironment == "xfce") {
          xfce.enable = true;
        })
        
        (mkIf (cfg.desktopEnvironment == "gnome") {
          gnome.enable = true;
        })
        
        (mkIf (cfg.desktopEnvironment == "kde") {
          plasma5.enable = true;
        })
      ];
      
      # Window Manager configuration  
      windowManager = mkMerge [
        (mkIf (cfg.desktopEnvironment == "i3") {
          i3.enable = true;
        })
      ];
    };

    # Additional packages based on desktop environment
    environment.systemPackages = with pkgs; mkMerge [
      (mkIf (cfg.desktopEnvironment == "xfce") [
        xfce.xfce4-terminal
        xfce.thunar
        xfce.xfce4-settings
      ])
      
      (mkIf (cfg.desktopEnvironment == "i3") [
        dmenu
        i3status
        i3lock
      ])
    ];
  };
}