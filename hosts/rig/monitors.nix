{ config, lib, pkgs, ... }:

{
  # Add xrandr command to X server startup
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --primary --mode 3440x1440 --rate 144 --output DP-3 --mode 2560x1440 --rate 144 --left-of DP-1
  '';
}
