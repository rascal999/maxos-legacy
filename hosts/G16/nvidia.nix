{ config, lib, pkgs, ... }:

{
  # Enable graphics
  hardware.graphics.enable = true;

  # Use modesetting and NVIDIA drivers
  services.xserver = {
    videoDrivers = [ "modesetting" "nvidia" ];
    
    # Basic X11 configuration
    extraConfig = ''
      Section "Device"
        Identifier "Intel Graphics"
        Driver "modesetting"
        BusID "PCI:0:2:0"
      EndSection

      Section "Device"
        Identifier "NVIDIA"
        Driver "nvidia"
        BusID "PCI:1:0:0"
      EndSection
    '';
  };

  # NVIDIA configuration
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;

    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Load Intel first, then NVIDIA
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "i915" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Configure module loading
  boot.extraModprobeConfig = ''
    options i915 force_probe=7d55
    options nvidia-drm modeset=1
  '';

  # Add kernel parameters
  boot.kernelParams = [
    "i915.force_probe=7d55"
    "nvidia-drm.modeset=1"
  ];

  # Basic OpenGL configuration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
}
