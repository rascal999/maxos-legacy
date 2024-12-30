{ config, pkgs, lib, ... }:

{
  # Enable Wayland and Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      mako
      wofi
      waybar
      grim
      slurp
      kanshi
      wdisplays
    ];
  };

  # XDG Portal for screen sharing
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable dconf for GTK settings
  programs.dconf.enable = true;

  # Environment variables for Wayland
  environment.sessionVariables = {
    # Wayland-specific
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    MOZ_ENABLE_WAYLAND = "1";
    
    # For better scaling
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    
    # For Java applications
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # User-specific Sway configuration
  home-manager.users.user = { pkgs, ... }: {
    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";  # Super key
        
        # Output configuration
        output = {
          "*" = {
            bg = "~/wallpapers/default.jpg fill";
          };
        };
        
        # Input configuration
        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_options = "caps:escape";
          };
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
          };
        };
        
        # Keybindings
        keybindings = let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in {
          # Basic bindings
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${modifier}+d" = "exec ${pkgs.wofi}/bin/wofi --show drun";
          "${modifier}+q" = "kill";
          "${modifier}+Shift+r" = "reload";
          "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'";
          
          # Screenshots
          "Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
          "${modifier}+Print" = "exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy";
          
          # Layout
          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+f" = "fullscreen";
          "${modifier}+Shift+space" = "floating toggle";
          
          # Focus
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";
          
          # Move
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";
          
          # Workspaces
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";
          
          # Move containers to workspaces
          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";
        };
        
        # Window rules
        window.commands = [
          {
            criteria = { app_id = "firefox"; };
            command = "inhibit_idle fullscreen";
          }
          {
            criteria = { app_id = "mpv"; };
            command = "inhibit_idle visible";
          }
        ];
        
        # Bars
        bars = [{
          position = "top";
          command = "${pkgs.waybar}/bin/waybar";
        }];
      };
      
      # Extra configuration
      extraConfig = ''
        # Idle configuration
        exec swayidle -w \
          timeout 300 'swaylock -f -c 000000' \
          timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
          before-sleep 'swaylock -f -c 000000'
          
        # Notification daemon
        exec mako
        
        # Screen temperature
        exec gammastep
        
        # GTK theme
        exec_always {
          gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'
          gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
          gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
          gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10'
        }
      '';
    };

    # Waybar configuration
    programs.waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "battery" "clock" "tray" ];
      }];
    };
  };
}
