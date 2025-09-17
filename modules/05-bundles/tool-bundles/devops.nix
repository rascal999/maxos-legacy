{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.devops;
in {
  options.modules.toolBundles.devops = {
    enable = mkEnableOption "DevOps tools bundle";
    
    profile = mkOption {
      type = types.enum [ "core" "cicd" "monitoring" "security" "complete" ];
      default = "core";
      description = "DevOps profile level";
    };
    
    enableContainerPlatform = mkOption {
      type = types.bool;
      default = true;
      description = "Enable container orchestration platform";
    };
    
    enableCICD = mkOption {
      type = types.bool;
      default = cfg.profile == "cicd" || cfg.profile == "complete";
      description = "Enable CI/CD pipeline tools";
    };
    
    enableMonitoring = mkOption {
      type = types.bool;
      default = cfg.profile == "monitoring" || cfg.profile == "complete";
      description = "Enable monitoring and observability";
    };
    
    enableSecurityScanning = mkOption {
      type = types.bool;
      default = cfg.profile == "security" || cfg.profile == "complete";
      description = "Enable security scanning and compliance";
    };
  };

  config = mkIf cfg.enable {
    maxos.tools = {
      # Layer 3 services (available)
      docker.enable = mkIf cfg.enableContainerPlatform true;
      k3s.enable = mkIf cfg.enableContainerPlatform true;

      # Layer 4 applications (now properly located)
      argocd.enable = mkIf cfg.enableCICD true;
      grafana.enable = mkIf cfg.enableMonitoring true;
      trivy.enable = mkIf cfg.enableSecurityScanning true;
      semgrep.enable = mkIf cfg.enableSecurityScanning true;
      syft.enable = mkIf cfg.enableSecurityScanning true;
      grype.enable = mkIf cfg.enableSecurityScanning true;
      
      # Cloud-native tools
      # Additional cloud-native tools would go here
    };
  };
}