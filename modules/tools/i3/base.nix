{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    i3status
    i3lock
    dmenu
  ];

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";  # Use Super key as modifier

      # Basic keybindings
      keybindings = lib.mkOptionDefault {
        # Terminal
        "${config.modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        
        # Program launcher
        "${config.modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        
        # Window management
        "${config.modifier}+Shift+q" = "kill";
        "${config.modifier}+f" = "fullscreen toggle";
        "${config.modifier}+Shift+space" = "floating toggle";
        
        # Layout management
        "${config.modifier}+s" = "layout stacking";
        "${config.modifier}+w" = "layout tabbed";
        "${config.modifier}+e" = "layout toggle split";
        
        # Focus
        "${config.modifier}+Left" = "focus left";
        "${config.modifier}+Down" = "focus down";
        "${config.modifier}+Up" = "focus up";
        "${config.modifier}+Right" = "focus right";
        
        # Moving windows
        "${config.modifier}+Shift+Left" = "move left";
        "${config.modifier}+Shift+Down" = "move down";
        "${config.modifier}+Shift+Up" = "move up";
        "${config.modifier}+Shift+Right" = "move right";
        
        # Restart/reload i3
        "${config.modifier}+Shift+c" = "reload";
        "${config.modifier}+Shift+r" = "restart";
      };

      # Shared workspace configuration
      workspaces = {
        "1" = { name = "1: term"; };
        "2" = { name = "2: web"; };
        "3" = { name = "3: code"; };
        "4" = { name = "4: files"; };
        "5" = { name = "5: media"; };
      };

      # Basic appearance settings
      bars = [{
        position = "bottom";
        statusCommand = "${pkgs.i3status}/bin/i3status";
        colors = {
          background = "#2e3440";
          statusline = "#eceff4";
          separator = "#4c566a";
        };
      }];

      # Window borders and gaps
      gaps = {
        inner = 5;
        outer = 0;
      };
    };
  };
}
