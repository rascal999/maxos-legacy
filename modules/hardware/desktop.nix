{ config, lib, pkgs, ... }:

# Hardware profile for desktop configurations

with lib;

let
  cfg = config.maxos.hardware.desktop;
in {
  options.maxos.hardware.desktop = {
    enable = mkEnableOption "Desktop hardware optimizations";
    
    performance = {
      governor = mkOption {
        type = types.enum [ "performance" "ondemand" "schedutil" ];
        default = "performance";
        description = "CPU governor for desktop performance";
      };
      
      highPerformance = mkOption {
        type = types.bool;
        default = true;
        description = "Enable high-performance optimizations";
      };
    };
    
    graphics = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable graphics acceleration";
      };
      
      nvidia = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA GPU support";
      };
      
      amd = mkOption {
        type = types.bool;
        default = false;
        description = "Enable AMD GPU support";
      };
    };
    
    audio = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable high-quality audio";
      };
      
      lowLatency = mkOption {
        type = types.bool;
        default = false;
        description = "Enable low-latency audio for production";
      };
    };
    
    storage = {
      ssd = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SSD optimizations";
      };
      
      trim = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic TRIM for SSDs";
      };
    };
  };

  config = mkIf cfg.enable {
    # Performance optimizations
    powerManagement.cpuFreqGovernor = mkIf cfg.performance.highPerformance cfg.performance.governor;
    
    # Kernel parameters for performance
    boot.kernelParams = mkIf cfg.performance.highPerformance [
      "mitigations=off"  # Disable CPU mitigations for performance
      "transparent_hugepage=always"
    ];

    # Graphics acceleration
    hardware.opengl = mkIf cfg.graphics.enable {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # NVIDIA support
    services.xserver.videoDrivers = mkIf cfg.graphics.nvidia [ "nvidia" ];
    hardware.nvidia = mkIf cfg.graphics.nvidia {
      modesetting.enable = true;
      powerManagement.enable = false; # Desktop doesn't need power saving
      powerManagement.finegrained = false;
      open = false; # Use proprietary driver
      nvidiaSettings = true;
    };

    # AMD GPU support
    services.xserver.videoDrivers = mkIf cfg.graphics.amd [ "amdgpu" ];
    
    # Audio configuration
    sound.enable = mkIf cfg.audio.enable true;
    hardware.pulseaudio.enable = mkIf cfg.audio.enable false; # Use PipeWire instead
    
    services.pipewire = mkIf cfg.audio.enable {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = cfg.audio.lowLatency;
    };

    # Real-time audio group
    users.users.${config.maxos.user.name}.extraGroups = mkIf cfg.audio.lowLatency [ "audio" ];

    # SSD optimizations
    services.fstrim.enable = mkIf (cfg.storage.ssd && cfg.storage.trim) true;
    
    # I/O scheduler for SSDs
    boot.kernelParams = mkIf cfg.storage.ssd [ "elevator=noop" ];

    # Desktop-specific packages
    environment.systemPackages = with pkgs; mkIf cfg.enable [
      glxinfo
      vulkan-tools
      pciutils
      usbutils
    ] ++ optionals cfg.graphics.nvidia [
      nvidia-docker
      nvidia-container-toolkit
      cudaPackages.cuda_nvcc
      cudaPackages.cuda_cudart
    ] ++ optionals cfg.audio.lowLatency [
      qjackctl
      carla
    ];

    # Enable container GPU support for NVIDIA
    hardware.nvidia-container-toolkit.enable = mkIf cfg.graphics.nvidia true;

    # Performance monitoring
    programs.htop.enable = mkIf cfg.performance.highPerformance true;
  };
}