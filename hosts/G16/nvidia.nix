{ config, lib, pkgs, ... }:

{
  # Enable graphics
  hardware.graphics.enable = true;

  # Use NVIDIA driver only
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    
    # Configure NVIDIA as primary GPU
    extraConfig = ''
      Section "ServerLayout"
        Identifier "layout"
        Screen 0 "nvidia"
      EndSection

      Section "Device"
        Identifier "nvidia"
        Driver "nvidia"
        BusID "PCI:1:0:0"
        Option "AllowEmptyInitialConfiguration" "true"
        Option "UseDisplayDevice" "none"
        Option "PrimaryGPU" "yes"
      EndSection

      Section "Screen"
        Identifier "nvidia"
        Device "nvidia"
        Option "AllowEmptyInitialConfiguration" "true"
      EndSection
    '';
  };

  # NVIDIA configuration
  hardware.nvidia = {
    # Use stable drivers
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Disable open-source drivers for stability
    open = false;
    
    # Enable nvidia-persistenced service
    nvidiaPersistenced = true;
    
    # Enable modesetting
    modesetting.enable = true;
    
    # Enable nvidia-settings
    nvidiaSettings = true;

    # Power management
    powerManagement = {
      enable = true;
      finegrained = false;  # Disable fine-grained for stability
    };

    # Force full composition pipeline for better performance
    forceFullCompositionPipeline = true;
  };

  # Load NVIDIA modules in correct order
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  
  # Configure module loading
  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
    options nvidia NVreg_RegistryDwords="EnableBrightnessControl=1"
  '';

  # Add kernel parameters for NVIDIA
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_UsePageAttributeTable=1"
  ];

  # Enable EDID for proper display detection
  services.xserver.screenSection = ''
    Option "UseEdid" "True"
    Option "ModeValidation" "NoMaxPClkCheck"
  '';
}
