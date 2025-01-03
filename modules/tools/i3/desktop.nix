{ config, lib, pkgs, ... }:

{
  imports = [ ./base.nix ];

  xsession.windowManager.i3.config = {
    # Desktop-specific startup applications
    startup = [
      { command = "nm-applet"; notification = false; }
      { command = "volumeicon"; notification = false; }
      { command = "flameshot"; notification = false; }
    ];

    # Additional workspace assignments for desktop applications
    assigns = {
      "2: web" = [{ class = "^Firefox$"; }];
      "3: code" = [{ class = "^Code$"; }];
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
