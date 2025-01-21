{ config, lib, pkgs, ... }:

{
  # Enable graphics
  hardware.graphics.enable = true;

  # Use modesetting driver
  services.xserver = {
    videoDrivers = [ "modesetting" ];
    
    # Basic X11 configuration
    extraConfig = ''
      Section "Device"
        Identifier "Intel Graphics"
        Driver "modesetting"
        BusID "PCI:0:2:0"
      EndSection
    '';
  };

  # Load Intel modules
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "i915" ];
  
  # Configure module loading
  boot.extraModprobeConfig = ''
    options i915 force_probe=7d55
  '';

  # Add kernel parameters
  boot.kernelParams = [
    "i915.force_probe=7d55"
  ];

  # Basic OpenGL configuration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
}
