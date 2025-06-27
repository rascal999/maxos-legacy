{ config, lib, pkgs, ... }:

{
  # Enable NVIDIA driver
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    
    # Basic X11 configuration
    extraConfig = ''
      Section "Device"
        Identifier "Intel Graphics"
        Driver "modesetting"
        BusID "PCI:0:2:0"
        Option "Backlight" "intel_backlight"
      EndSection

      Section "Device"
        Identifier "NVIDIA"
        Driver "nvidia"
        BusID "PCI:1:0:0"
      EndSection
    '';
  };

  # Load Intel and NVIDIA modules
  boot.initrd.kernelModules = [ "i915" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelModules = [ "i915" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Configure module loading
  boot.extraModprobeConfig = ''
    options i915 force_probe=7d55 enable_backlight=1
    blacklist nouveau
  '';

  # Add kernel parameters
  boot.kernelParams = [
    "i915.force_probe=7d55"
    "rd.driver.blacklist=nouveau"
    "modprobe.blacklist=nouveau"
    "acpi_backlight=vendor"
    "quiet"
    "splash"
    "nvidia-drm.modeset=1"
  ];

  # Enable NVIDIA hardware
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Enable NVIDIA Container Runtime
  hardware.nvidia-container-toolkit.enable = lib.mkForce true;

  # Basic graphics configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      nvidia-vaapi-driver
    ];
  };
}
