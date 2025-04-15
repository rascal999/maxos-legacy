{ config, pkgs, lib, ... }:

{
  options.modules.tools.remmina = {
    enable = lib.mkEnableOption "Remmina remote desktop client";
  };

  config = lib.mkIf config.modules.tools.remmina.enable {
    # Add Remmina and related packages to system packages
    environment.systemPackages = with pkgs; [
      remmina
      # Optional dependencies for various protocols
      freerdp    # For RDP support
      libvncserver  # For VNC support
      spice-gtk  # For SPICE support
    ];
  };
}