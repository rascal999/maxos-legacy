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
      modifier = "Mod1";  # Use Alt key as modifier

      # Basic keybindings
      keybindings = lib.mkOptionDefault {
        # Terminal (tmux)
        "Mod1+t" = "exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux";
        
        # Program launcher
        "Mod1+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        
        # Window management
        "Mod1+Shift+q" = "kill";
        "Mod1+f" = "fullscreen toggle";
        "Mod1+Shift+space" = "floating toggle";
        
        # Layout management
        "Mod1+s" = "layout stacking";
        "Mod1+w" = "layout tabbed";
        "Mod1+e" = "layout toggle split";
        
        # Focus
        "Mod1+Left" = "focus left";
        "Mod1+Down" = "focus down";
        "Mod1+Up" = "focus up";
        "Mod1+Right" = "focus right";
        
        # Moving windows
        "Mod1+Shift+Left" = "move left";
        "Mod1+Shift+Down" = "move down";
        "Mod1+Shift+Up" = "move up";
        "Mod1+Shift+Right" = "move right";
        
        # Restart/reload i3
        "Mod1+Shift+c" = "reload";
        "Mod1+Shift+r" = "restart";
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

      # Window appearance
      window.border = 0;
      gaps = {
        inner = 0;
        outer = 0;
        smartGaps = true;
      };
    };
  };
}
