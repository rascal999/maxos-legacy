{ config, lib, pkgs, ... }:

{
  # Add xrandr command to X server startup
  services.xserver.displayManager.setupCommands = ''
    # Use auto-detection for available modes first
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
    
    # Configure the specific displays for Rig host
    # DP-2 is the ultra-wide display, set as primary
    # DP-4 is the secondary display, positioned to the right
    if ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-2 connected" && ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-4 connected"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --primary --auto --output DP-4 --auto --right-of DP-2
    # Fallback if only DP-2 is connected
    elif ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-2 connected"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --primary --auto
    # Fallback if only DP-4 is connected
    elif ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-4 connected"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-4 --primary --auto
    fi
  '';
}
