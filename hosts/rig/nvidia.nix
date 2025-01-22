{ config, lib, pkgs, ... }:

{
  # Enable NVIDIA drivers
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    
    # Basic X11 configuration
    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    '';
  };

  # NVIDIA driver configuration
  hardware.nvidia = {
    # Use the latest driver
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Enable modesetting
    modesetting.enable = true;

    # Enable the NVIDIA settings menu
    nvidiaSettings = true;

    # OpenGL configuration
    prime = {
      sync.enable = false;  # Desktop doesn't need Optimus/PRIME
      offload.enable = false;
    };
  };

  # Configure module loading
  boot.extraModprobeConfig = ''
    blacklist nouveau
  '';

  # Add kernel parameters
  boot.kernelParams = [
    "nvidia-drm.modeset=1"  # Enable DRM kernel mode setting
    "rd.driver.blacklist=nouveau"
    "modprobe.blacklist=nouveau"
  ];

  # Basic graphics configuration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;  # Enable 32-bit support for Steam games
  };

  # Add NVIDIA-specific packages
  environment.systemPackages = with pkgs; [
    glxinfo
    vulkan-tools
    nvidia-vaapi-driver
    libva-utils
  ];
}
