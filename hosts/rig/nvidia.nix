{ config, lib, pkgs, ... }:

{
  # Enable NVIDIA drivers
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    
    # Basic X11 configuration
    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=Off, ForceCompositionPipeline=Off}"
      Option "TripleBuffer" "off"
      Option "AllowIndirectGLXProtocol" "off"
      Option "VariableRefresh" "off"
      Option "MaxFramesAllowed" "1"
      Option "SyncToVBlank" "1"
      Option "RRRotate" "normal"
      Option "UseNvKmsCompositionPipeline" "1"
      Option "UseTimerFD" "1"
      Option "SwapbuffersWait" "1"
    '';
  };

  # NVIDIA driver configuration
  hardware.nvidia = {
    # Use the beta driver for better compatibility with newer kernels/features
    package = config.boot.kernelPackages.nvidiaPackages.beta; # Changed from .production

    # Enable modesetting
    modesetting.enable = true;

    # Enable the NVIDIA settings menu
    nvidiaSettings = true;

    # Use open-source kernel modules (fix for kernel 6.15 GPL symbol issue)
    open = true;

    # OpenGL configuration
    prime = {
      sync.enable = false;  # Desktop doesn't need Optimus/PRIME
      offload.enable = false;
    };
    # nvidia-container-toolkit was here, moved to top-level hardware
  };

  # Enable nvidia-container-toolkit for Docker GPU passthrough
  hardware.nvidia-container-toolkit.enable = true;

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
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Enable 32-bit support for Steam games
  };

  # Add NVIDIA-specific packages
  environment.systemPackages = with pkgs; [
    glxinfo
    vulkan-tools
    nvidia-vaapi-driver
    libva-utils
  ];
}
