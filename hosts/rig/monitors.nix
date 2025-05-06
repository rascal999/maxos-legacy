{ config, lib, pkgs, ... }:

{
  # Add xrandr command to X server startup
  services.xserver.displayManager.setupCommands = ''
    # Use auto-detection for available modes first
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
    
    # Configure the specific displays for Rig host
    # DP-0 is the ultra-wide display, set as primary
    # DP-4 is the secondary display, positioned to the left
    if ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-0 connected" && ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-4 connected"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --primary --auto --output DP-4 --auto --left-of DP-0
    # Fallback if only DP-0 is connected
    elif ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-0 connected"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --primary --auto
    # Fallback if only DP-4 is connected
    elif ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-4 connected"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-4 --primary --auto
    fi
  '';
}
