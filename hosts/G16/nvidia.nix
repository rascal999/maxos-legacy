{ config, lib, pkgs, ... }:

{
  # Enable graphics
  hardware.graphics.enable = true;

  # Blacklist Intel graphics
  boot.blacklistedKernelModules = [ "i915" ];

  # Use NVIDIA driver only
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    
    # Basic X11 configuration
    extraConfig = ''
      Section "Device"
        Identifier "nvidia"
        Driver "nvidia"
        BusID "PCI:1:0:0"
      EndSection

      Section "Screen"
        Identifier "screen"
        Device "nvidia"
        Option "AllowEmptyInitialConfiguration" "true"
      EndSection

      Section "Module"
        Load "modesetting"
      EndSection
    '';
  };

  # NVIDIA configuration
  hardware.nvidia = {
    # Use stable drivers
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Disable open-source drivers
    open = false;
    
    # Enable modesetting
    modesetting.enable = true;
    
    # Enable nvidia-settings
    nvidiaSettings = true;

    # Power management
    powerManagement = {
      enable = true;
      finegrained = false;
    };
  };

  # Load NVIDIA modules
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  
  # Configure module loading
  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
  '';

  # Add kernel parameters for NVIDIA
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nomodeset"
  ];
}
