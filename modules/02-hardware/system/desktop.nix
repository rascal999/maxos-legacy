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
    
    wireless = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable wireless networking";
      };
      
      bluetooth = mkOption {
        type = types.bool;
        default = true;
        description = "Enable bluetooth support";
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
    
    # Combined kernel parameters
    boot.kernelParams = 
      (optionals cfg.performance.highPerformance [
        "mitigations=off"  # Disable CPU mitigations for performance
        "transparent_hugepage=always"
      ])
      ++ (optionals cfg.storage.ssd [
        "elevator=noop"
      ]);

    # Graphics acceleration
    hardware.opengl = mkIf cfg.graphics.enable {
      enable = true;
      # driSupport is deprecated and automatically enabled
      driSupport32Bit = true;
    };

    # GPU drivers (mutually exclusive)
    services.xserver.videoDrivers = 
      if cfg.graphics.nvidia then [ "nvidia" ]
      else if cfg.graphics.amd then [ "amdgpu" ]
      else [ ];

    # NVIDIA configuration
    hardware.nvidia = mkIf cfg.graphics.nvidia {
      modesetting.enable = mkDefault true;
      powerManagement.enable = mkDefault false; # Desktop doesn't need power saving
      powerManagement.finegrained = mkDefault false;
      open = mkDefault false; # Use proprietary driver
      nvidiaSettings = mkDefault true;
    };
    
    # Audio configuration
    services.pipewire = mkIf cfg.audio.enable {
      enable = mkDefault true;
      alsa.enable = mkDefault true;
      alsa.support32Bit = mkDefault true;
      pulse.enable = mkDefault true;
      jack.enable = mkDefault cfg.audio.lowLatency;
    };

    # Real-time audio group
    users.users.${config.maxos.user.name}.extraGroups = mkIf cfg.audio.lowLatency [ "audio" ];

    # SSD optimizations
    services.fstrim.enable = mkIf (cfg.storage.ssd && cfg.storage.trim) true;

    # Desktop-specific packages
    environment.systemPackages = mkIf cfg.enable (with pkgs; [
      glxinfo
      vulkan-tools
      pciutils
      usbutils
    ] ++ (optionals cfg.graphics.nvidia [
      nvidia-docker
      nvidia-container-toolkit
      cudaPackages.cuda_nvcc
      cudaPackages.cuda_cudart
    ]) ++ (optionals cfg.audio.lowLatency [
      qjackctl
      carla
    ]) ++ (optionals cfg.wireless.bluetooth [
      bluez
    ]));

    # Wireless networking
    networking.wireless.enable = mkIf cfg.wireless.enable false; # Use NetworkManager instead
    networking.networkmanager.enable = mkIf cfg.wireless.enable true;

    # Bluetooth
    hardware.bluetooth = mkIf cfg.wireless.bluetooth {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = mkIf cfg.wireless.bluetooth true;

    # Enable container GPU support for NVIDIA
    hardware.nvidia-container-toolkit.enable = mkIf cfg.graphics.nvidia true;

    # Performance monitoring
    programs.htop.enable = mkIf cfg.performance.highPerformance true;
  };
}