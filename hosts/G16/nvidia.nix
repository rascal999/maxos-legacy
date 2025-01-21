{ config, lib, pkgs, ... }:

{
  # Enable graphics
  hardware.graphics.enable = true;

  # Use both modesetting and NVIDIA drivers
  services.xserver = {
    videoDrivers = [ "modesetting" "nvidia" ];
    
    # Configure hybrid graphics
    extraConfig = ''
      Section "ServerLayout"
        Identifier "layout"
        Screen 0 "nvidia"
        Inactive "intel"
        Option "AllowNVIDIAGPUScreens"
      EndSection

      Section "Device"
        Identifier "intel"
        Driver "modesetting"
        BusID "PCI:0:2:0"
      EndSection

      Section "Screen"
        Identifier "intel"
        Device "intel"
      EndSection

      Section "Device"
        Identifier "nvidia"
        Driver "nvidia"
        BusID "PCI:1:0:0"
        Option "AllowEmptyInitialConfiguration"
        Option "AllowExternalGpus"
        Option "RegistryDwords" "EnableBrightnessControl=1"
      EndSection

      Section "Screen"
        Identifier "nvidia"
        Device "nvidia"
        Option "AllowEmptyInitialConfiguration"
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

  # Enable EDID for proper display detection
  services.xserver.screenSection = ''
    Option "UseEdid" "True"
  '';
}
