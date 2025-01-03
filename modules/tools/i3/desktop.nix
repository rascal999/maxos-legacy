{ config, lib, pkgs, ... }:

{
  imports = [ ./base.nix ];

  xsession.windowManager.i3.config = {
    # Desktop-specific startup applications
    startup = [
      { command = "nm-applet"; notification = false; }
      { command = "volumeicon"; notification = false; }
      { command = "flameshot"; notification = false; }
      { command = "firefox"; notification = false; }
    ];

    # Additional workspace assignments for desktop applications
    assigns = {
      "1" = [{ class = "^Firefox$"; }];
      "2" = [{ class = "^Code$"; }];
      "5: media" = [{ class = "^Spotify$"; }];
    };
  };

  # Additional packages for desktop environment
  home.packages = with pkgs; [
    flameshot
    networkmanagerapplet
    volumeicon
    light
    pcmanfm
    firefox
  ];
}
