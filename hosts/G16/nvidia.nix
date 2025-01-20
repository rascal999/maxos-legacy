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
    # Optimus PRIME configuration
    prime = {
      # Use offload mode
      sync.enable = false;  # Ensure we're not using sync mode
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # iGPU for power saving, NVIDIA GPU for rendering
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = false;
  };

  # Enable DRM kernel modesetting
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
}
