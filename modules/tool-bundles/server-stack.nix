{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.serverStack;
in {
  options.modules.toolBundles.serverStack = {
    enable = mkEnableOption "Server infrastructure bundle";
    
    profile = mkOption {
      type = types.enum [ "minimal" "standard" "enterprise" ];
      default = "standard";
      description = "Server profile level";
    };
    
    enableInfrastructure = mkOption {
      type = types.bool;
      default = true;
      description = "Enable infrastructure tools (networking, storage)";
    };
    
    enableMonitoring = mkOption {
      type = types.bool;
      default = cfg.profile != "minimal";
      description = "Enable monitoring and observability";
    };
    
    enableBackup = mkOption {
      type = types.bool;
      default = true;
      description = "Enable backup solutions";
    };
  };

  config = mkIf cfg.enable {
    modules.tools = {
      # Core infrastructure
      blocky.enable = mkIf cfg.enableInfrastructure true;
      docker.enable = true;  # Always needed for server workloads
      
      # Backup and storage
      restic.enable = mkIf cfg.enableBackup true;
      linuxquota.enable = mkIf cfg.enableInfrastructure true;
      
      # Monitoring (standard and enterprise)
      grafana.enable = mkIf cfg.enableMonitoring true;
      
      # Enterprise additions
      k3s.enable = mkIf (cfg.profile == "enterprise") true;
      
      # Security essentials
      openssl.enable = true;
      wireguard.enable = mkIf cfg.enableInfrastructure true;
    };
  };
}