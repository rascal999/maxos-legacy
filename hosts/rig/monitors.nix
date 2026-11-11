{ config, lib, pkgs, ... }:

{
  # Add xrandr command to X server startup
  services.xserver.displayManager.setupCommands = ''
    # Use auto-detection for available modes first
    ${pkgs.xrandr}/bin/xrandr --auto
    
    # Configure the specific displays for Rig host
    # DP-4 is the ultra-wide display, set as primary (cables swapped 2026-10-08)
    # DP-2 is the secondary display, positioned to the right
    if ${pkgs.xrandr}/bin/xrandr | grep -q "DP-2 connected" && ${pkgs.xrandr}/bin/xrandr | grep -q "DP-4 connected"; then
      ${pkgs.xrandr}/bin/xrandr --output DP-4 --primary --auto --output DP-2 --auto --right-of DP-4
    # Fallback if only DP-4 is connected
    elif ${pkgs.xrandr}/bin/xrandr | grep -q "DP-4 connected"; then
      ${pkgs.xrandr}/bin/xrandr --output DP-4 --primary --auto
    # Fallback if only DP-2 is connected
    elif ${pkgs.xrandr}/bin/xrandr | grep -q "DP-2 connected"; then
      ${pkgs.xrandr}/bin/xrandr --output DP-2 --primary --auto
    fi
  '';
}
