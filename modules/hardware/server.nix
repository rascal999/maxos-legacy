{ config, lib, pkgs, ... }:

# Hardware profile for server configurations

with lib;

let
  cfg = config.maxos.hardware.server;
in {
  options.maxos.hardware.server = {
    enable = mkEnableOption "Server hardware optimizations";
    
    performance = {
      governor = mkOption {
        type = types.enum [ "performance" "powersave" "ondemand" ];
        default = "performance";
        description = "CPU governor for server workloads";
      };
      
      enableTurbo = mkOption {
        type = types.bool;
        default = true;
        description = "Enable CPU turbo boost";
      };
    };
    
    memory = {
      hugepages = mkOption {
        type = types.bool;
        default = false;
        description = "Enable transparent hugepages for better memory performance";
      };
      
      swappiness = mkOption {
        type = types.int;
        default = 10;
        description = "VM swappiness value (0-100, lower = less swapping)";
      };
    };
    
    network = {
      optimizeForThroughput = mkOption {
        type = types.bool;
        default = true;
        description = "Optimize network settings for high throughput";
      };
      
      enableBBR = mkOption {
        type = types.bool;
        default = true;
        description = "Enable BBR congestion control";
      };
    };
    
    storage = {
      schedulerOptimization = mkOption {
        type = types.bool;
        default = true;
        description = "Optimize I/O scheduler for server workloads";
      };
      
      enableNuma = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NUMA optimizations";
      };
    };
    
    monitoring = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable hardware monitoring";
      };
      
      sensors = mkOption {
        type = types.bool;
        default = true;
        description = "Enable temperature sensors";
      };
    };
  };

  config = mkIf cfg.enable {
    # CPU performance
    powerManagement.cpuFreqGovernor = cfg.performance.governor;
    
    # Kernel parameters for server optimization
    boot.kernelParams = [
      # Memory management
      "vm.swappiness=${toString cfg.memory.swappiness}"
    ] ++ optionals cfg.memory.hugepages [
      "transparent_hugepage=always"
      "hugepagesz=2M"
      "hugepages=1024"
    ] ++ optionals cfg.performance.enableTurbo [
      "intel_pstate=active"
    ] ++ optionals cfg.network.enableBBR [
      "net.core.default_qdisc=fq"
      "net.ipv4.tcp_congestion_control=bbr"
    ];

    # Sysctl optimizations for servers
    boot.kernel.sysctl = mkMerge [
      # Network optimizations
      (mkIf cfg.network.optimizeForThroughput {
        # TCP buffer sizes
        "net.core.rmem_default" = 262144;
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_default" = 262144;
        "net.core.wmem_max" = 16777216;
        "net.ipv4.tcp_rmem" = "4096 65536 16777216";
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
        
        # Connection handling
        "net.ipv4.tcp_max_syn_backlog" = 4096;
        "net.core.netdev_max_backlog" = 5000;
        "net.core.somaxconn" = 1024;
        
        # TCP optimizations
        "net.ipv4.tcp_window_scaling" = 1;
        "net.ipv4.tcp_timestamps" = 1;
        "net.ipv4.tcp_sack" = 1;
      })
      
      # Memory optimizations
      {
        "vm.dirty_ratio" = 15;
        "vm.dirty_background_ratio" = 5;
        "vm.vfs_cache_pressure" = 50;
      }
    ];

    # I/O scheduler optimization
    services.udev.extraRules = mkIf cfg.storage.schedulerOptimization ''
      # Set mq-deadline for HDDs and none for SSDs/NVMe
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
      ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
    '';

    # Hardware monitoring
    hardware.cpu.intel.updateMicrocode = mkIf cfg.monitoring.enable true;
    hardware.cpu.amd.updateMicrocode = mkIf cfg.monitoring.enable true;
    
    # Temperature monitoring
    programs.lm-sensors.enable = mkIf cfg.monitoring.sensors true;

    # Server-specific packages
    environment.systemPackages = with pkgs; mkIf cfg.enable [
      htop
      iotop
      nethogs
      tcpdump
      ethtool
      smartmontools
    ] ++ optionals cfg.monitoring.enable [
      lm_sensors
      hddtemp
      psensor
    ];

    # Systemd service optimizations
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=10s
    '';

    # Disable unnecessary services for servers
    services.udisks2.enable = mkDefault false;
    services.power-profiles-daemon.enable = mkDefault false;
    
    # Enable system statistics collection
    services.sysstat.enable = mkIf cfg.monitoring.enable true;

    # NUMA optimizations
    boot.kernelParams = mkIf cfg.storage.enableNuma [
      "numa_balancing=enable"
    ];
  };
}