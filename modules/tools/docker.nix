{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.docker;
in {
  options.modules.tools.docker = {
    enable = mkEnableOption "Docker containerization platform";
    
    liveRestore = mkOption {
      type = types.bool;
      default = false;
      description = "Enable live restore to keep containers running during daemon restarts (disabled for Kind compatibility)";
    };
    
    enableExperimental = mkOption {
      type = types.bool;
      default = false;
      description = "Enable experimental Docker features";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      liveRestore = cfg.liveRestore;
      # Configure daemon settings for better Kubernetes compatibility
      daemon.settings = {
      # Use systemd as cgroup driver (recommended for Kubernetes)
      "exec-opts" = ["native.cgroupdriver=systemd"];
      # Enable IPv6 support
      "ipv6" = true;
      "fixed-cidr-v6" = "fd00::/80";
      # Configure logging
      "log-driver" = "journald";
      # Note: journald driver doesn't support max-size/max-file options
      # Log rotation is handled by systemd's journald service
      # Storage driver configuration
      "storage-driver" = "overlay2";
      # Network configuration for better container networking
      "default-address-pools" = [
        {
          "base" = "172.17.0.0/12";
          "size" = 24;
        }
        {
          "base" = "192.168.0.0/16";
          "size" = 24;
        }
      ];
      # Enable experimental features for better Kind support
      "experimental" = cfg.enableExperimental;
      # Configure for better performance with many containers
      "max-concurrent-downloads" = 10;
      "max-concurrent-uploads" = 5;
      };
    };
    
    # Ensure Docker starts after network is ready
    systemd.services.docker = {
      after = [ "network-online.target" "firewall.service" ];
      wants = [ "network-online.target" ];
    };
  };
}