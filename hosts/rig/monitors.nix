{ config, lib, pkgs, ... }:

{
  # Add xrandr command to X server startup
  services.xserver.displayManager.setupCommands = ''
    # Use auto-detection for available modes instead of hardcoding resolutions
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
    
    # Set DP-1 as primary if it exists
    if ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-1 connected"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --primary
    fi
    
    # Position DP-3 to the left of DP-1 if both exist
    if ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-1 connected" && ${pkgs.xorg.xrandr}/bin/xrandr | grep -q "DP-3 connected"; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --left-of DP-1
    fi
  '';
}
