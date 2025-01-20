{ config, lib, pkgs, ... }:

{
  # Enable graphics
  hardware.graphics.enable = true;

  # Use modesetting and NVIDIA drivers
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    
    # Configure NVIDIA as primary GPU
    extraConfig = ''
      Section "Device"
        Identifier "NVIDIA Card"
        Driver "nvidia"
        BusID "PCI:1:0:0"
      EndSection

      Section "Screen"
        Identifier "Screen0"
        Device "NVIDIA Card"
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

  # Load NVIDIA modules
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
  ];

  # Enable EDID for proper display detection
  services.xserver.screenSection = ''
    Option "UseEdid" "True"
  '';
}
