{ config, lib, pkgs, ... }:

{
  xsession.windowManager.i3.config = {
    # Basic appearance settings
    bars = lib.mkDefault [{
      position = "bottom";
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
      extraConfig = ''
        ${if builtins.getEnv "HOST" == "rig" then "tray_output DP-0" else "tray_output primary"}
      '';
      colors = {
        background = "#000000";
        statusline = "#eceff4";
        separator = "#000000";
        focusedWorkspace = {
          background = "#002b36";
          border = "#002b36";
          text = "#ffffff";
        };
        activeWorkspace = {
          background = "#002b36";
          border = "#002b36";
          text = "#ffffff";
        };
        inactiveWorkspace = {
          background = "#000000";
          border = "#000000";
          text = "#666666";
        };
        urgentWorkspace = {
          background = "#2b0000";
          border = "#2b0000";
          text = "#DC322F";
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
