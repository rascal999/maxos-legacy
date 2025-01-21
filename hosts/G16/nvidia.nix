{ config, lib, pkgs, ... }:

{
  # Enable graphics
  hardware.graphics.enable = true;

  # Use modesetting driver
  services.xserver = {
    videoDrivers = [ "modesetting" ];
    
    # Basic X11 configuration
    extraConfig = ''
      Section "Device"
        Identifier "Intel Graphics"
        Driver "modesetting"
        BusID "PCI:0:2:0"
        Option "Backlight" "intel_backlight"
      EndSection
    '';
  };

  # Load Intel modules
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "i915" ];
  
  # Configure module loading
  boot.extraModprobeConfig = ''
    options i915 force_probe=7d55 enable_backlight=1
    blacklist nouveau
  '';

  # Add kernel parameters from G16 2024 guide
  boot.kernelParams = [
    "i915.force_probe=7d55"
    "rd.driver.blacklist=nouveau"
    "modprobe.blacklist=nouveau"
    "acpi_backlight=vendor"
    "quiet"
    "splash"
    "nvidia-drm.modeset=1"
  ];

  # Basic graphics configuration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
}
