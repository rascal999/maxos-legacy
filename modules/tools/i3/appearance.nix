{ config, lib, pkgs, ... }:

{
  xsession.windowManager.i3.config = {
    # Basic appearance settings
    bars = [{
      position = "bottom";
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
      colors = {
        background = "#000000";
        statusline = "#eceff4";
        separator = "#000000";
        focusedWorkspace = {
          background = "#5e81ac";
          border = "#5e81ac";
          text = "#eceff4";
        };
        activeWorkspace = {
          background = "#4c566a";
          border = "#4c566a";
          text = "#eceff4";
        };
        inactiveWorkspace = {
          background = "#3b4252";
          border = "#3b4252";
          text = "#eceff4";
        };
        urgentWorkspace = {
          background = "#bf616a";
          border = "#bf616a";
          text = "#eceff4";
        };
      };
      fonts = {
        names = ["JetBrainsMono Nerd Font"];
        size = 11.0;
      };
    }];

    # Window appearance
    gaps = {
      inner = 0;
      outer = 0;
      smartGaps = true;
    };

    # Window decorations
    window = {
      border = 0;
      titlebar = false;
      commands = [
        { command = "border pixel 0"; criteria = { class = "^.*"; }; }
      ];
    };
  };
}
