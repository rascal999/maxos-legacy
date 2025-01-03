{ config, lib, pkgs, ... }:

{
  programs.home-manager.enable = true;
  
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
        "Mod4+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        
        # Program launcher
        "Mod4+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        
        # Window management
        "Mod4+Shift+q" = "kill";
        "Mod4+f" = "fullscreen toggle";
        "Mod4+Shift+space" = "floating toggle";
        
        # Layout management
        "Mod4+s" = "layout stacking";
        "Mod4+w" = "layout tabbed";
        "Mod4+e" = "layout toggle split";
        
        # Focus
        "Mod4+Left" = "focus left";
        "Mod4+Down" = "focus down";
        "Mod4+Up" = "focus up";
        "Mod4+Right" = "focus right";
        
        # Moving windows
        "Mod4+Shift+Left" = "move left";
        "Mod4+Shift+Down" = "move down";
        "Mod4+Shift+Up" = "move up";
        "Mod4+Shift+Right" = "move right";
        
        # Restart/reload i3
        "Mod4+Shift+c" = "reload";
        "Mod4+Shift+r" = "restart";
      };

      # Workspace configuration
      workspaceOutputAssign = [
        { workspace = "1: term"; output = "primary"; }
        { workspace = "2: web"; output = "primary"; }
        { workspace = "3: code"; output = "primary"; }
        { workspace = "4: files"; output = "primary"; }
        { workspace = "5: media"; output = "primary"; }
      ];

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
