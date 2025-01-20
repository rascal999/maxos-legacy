{ config, lib, pkgs, ... }:

{
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Use NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA configuration
  hardware.nvidia = {
    # Use stable drivers
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Enable open-source drivers
    open = true;
    
    # Enable nvidia-persistenced service
    nvidiaPersistenced = true;
    
    # Enable modesetting
    modesetting.enable = true;
    
    # Enable nvidia-settings
    nvidiaSettings = true;
    
    # Optimus PRIME configuration
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Bus IDs for hybrid graphics
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # Force full composition pipeline for better performance
    forceFullCompositionPipeline = true;
  };

  # Ensure NVIDIA modules are built and loaded
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Configure module loading
  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
    options nvidia NVreg_RegistryDwords="EnableBrightnessControl=1"
  '';

  # Add kernel parameters for display handling
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia-drm.modeset=1"
    "video=DP-2:D"  # Disable problematic DP-2 output
  ];

  # Configure Xorg for EDID issues
  services.xserver.screenSection = ''
    Option "UseEdid" "False"
    Option "IgnoreEDID" "True"
    Option "CustomEDID" "DP-2:/dev/null"
  '';
}
