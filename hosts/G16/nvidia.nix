{ config, lib, pkgs, ... }:

{
  # Enable graphics
  hardware.graphics.enable = true;

  # Use both modesetting and NVIDIA drivers
  services.xserver = {
    videoDrivers = [ "modesetting" "nvidia" ];
    
    # Configure hybrid graphics
    extraConfig = ''
      Section "OutputClass"
        Identifier "intel"
        MatchDriver "i915"
        Driver "modesetting"
      EndSection

      Section "OutputClass"
        Identifier "nvidia"
        MatchDriver "nvidia-drm"
        Driver "nvidia"
        Option "AllowEmptyInitialConfiguration"
        Option "PrimaryGPU" "yes"
        ModulePath "/run/current-system/sw/lib/xorg/modules"
        ModulePath "/run/current-system/sw/lib/xorg/modules/drivers"
      EndSection
    '';
  };

  # NVIDIA configuration
  hardware.nvidia = {
    # Use beta drivers for Arc compatibility
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    
    # Enable open kernel modules
    open = true;
    
    # Enable modesetting
    modesetting.enable = true;
    
    # Enable nvidia-settings
    nvidiaSettings = true;

    # Configure PRIME for Intel Arc + NVIDIA
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      
      # Bus IDs for hybrid graphics
      intelBusId = "PCI:0:2:0";  # Meteor Lake-P Arc
      nvidiaBusId = "PCI:1:0:0";  # RTX 4070 Max-Q
    };

    # Power management
    powerManagement = {
      enable = true;
      finegrained = true;
    };
  };

  # Load Intel first, then NVIDIA
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "i915" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  
  # Configure module loading
  boot.extraModprobeConfig = ''
    options i915 force_probe=7d55
    options nvidia-drm modeset=1
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
    options nvidia NVreg_RegistryDwords="EnableBrightnessControl=1"
  '';

  # Add kernel parameters
  boot.kernelParams = [
    "i915.force_probe=7d55"
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # Hardware acceleration configuration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-compute-runtime # OpenCL for Arc
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Environment variables for hardware acceleration
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver
    VDPAU_DRIVER = "va_gl"; # Use VDPAU over VAAPI
  };
}
