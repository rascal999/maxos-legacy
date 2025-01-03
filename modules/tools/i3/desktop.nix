{ config, lib, pkgs, ... }:

{
  imports = [ ./base.nix ];

  xsession.windowManager.i3.config = {
    # Desktop-specific keybindings
    keybindings = lib.mkOptionDefault {
      # Screenshot bindings
      "Print" = "exec ${pkgs.flameshot}/bin/flameshot gui";
      "Shift+Print" = "exec ${pkgs.flameshot}/bin/flameshot full";

      # Media controls
      "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
      
      # Brightness controls
      "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 5";
      "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 5";

      # Quick launch frequently used applications
      "${config.modifier}+b" = "exec ${pkgs.firefox}/bin/firefox";
      "${config.modifier}+n" = "exec ${pkgs.pcmanfm}/bin/pcmanfm";
      "${config.modifier}+l" = "exec ${pkgs.i3lock}/bin/i3lock -c 000000";
    };

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
