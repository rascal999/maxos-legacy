{ config, lib, pkgs, ... }:

{
  imports = [ ./base.nix ];

  xsession.windowManager.i3.config = {
    # Enable workspace back and forth
    workspaceAutoBackAndForth = true;

    # Desktop-specific startup applications
    startup = [
      # Add small delays to prevent race conditions
      { command = "sleep 1 && ${pkgs.networkmanagerapplet}/bin/nm-applet"; notification = false; }
      # Use pactl for volume control since we're using PipeWire
      { command = "sleep 2 && ${pkgs.pavucontrol}/bin/pavucontrol --start-hidden"; notification = false; }
      { command = "sleep 1 && ${pkgs.flameshot}/bin/flameshot"; notification = false; }
    ];
  };

  # Additional packages for desktop environment
  home.packages = with pkgs; [
    flameshot
    networkmanagerapplet
    pavucontrol
    light
    pcmanfm
  ];
}
