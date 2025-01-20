{ config, lib, pkgs, ... }:

{
  # NVIDIA configuration
  hardware.nvidia = {
    prime = {
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
