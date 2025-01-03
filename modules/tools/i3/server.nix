{ config, lib, pkgs, ... }:

{
  imports = [ ./base.nix ];

  xsession.windowManager.i3.config = {
    # Simplified keybindings for server setup
    keybindings = lib.mkOptionDefault {
      # Basic window management only
      "${config.modifier}+q" = "kill";
      "${config.modifier}+l" = "exec ${pkgs.i3lock}/bin/i3lock -c 000000";
    };

    # Minimal workspace configuration
    workspaces = {
      "1" = { name = "1: term"; };
      "2" = { name = "2: web"; };
      "3" = { name = "3: logs"; };
    };

    # Minimal bar configuration
    bars = [{
      position = "bottom";
      statusCommand = "${pkgs.i3status}/bin/i3status";
      mode = "hide";  # Hide bar by default
    }];

    # Disable gaps for server setup
    gaps = {
      inner = 0;
      outer = 0;
    };
  };

  # Minimal package set for server
  home.packages = with pkgs; [
    i3status
    i3lock
  ];
}
