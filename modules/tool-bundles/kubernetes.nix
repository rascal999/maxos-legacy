{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.kubernetes;
in {
  options.modules.toolBundles.kubernetes = {
    enable = mkEnableOption "Kubernetes tools bundle";
    
    profile = mkOption {
      type = types.enum [ "developer" "admin" "devops" ];
      default = "developer";
      description = "Kubernetes usage profile";
    };
    
    enableLocalCluster = mkOption {
      type = types.bool;
      default = cfg.profile == "developer" || cfg.profile == "devops";
      description = "Enable local Kubernetes clusters (Kind, K3s)";
    };
    
    enableGitOps = mkOption {
      type = types.bool;
      default = cfg.profile == "admin" || cfg.profile == "devops";
      description = "Enable GitOps tools (ArgoCD)";
    };
    
    enableDevelopmentWorkflow = mkOption {
      type = types.bool;
      default = cfg.profile == "developer" || cfg.profile == "devops";
      description = "Enable development workflow tools";
    };
    
    enableProductionTools = mkOption {
      type = types.bool;
      default = cfg.profile == "admin";
      description = "Enable production-grade tools (Traefik, monitoring)";
    };
  };

  config = mkIf cfg.enable {
    modules.tools = {
      # Container runtime (always needed)
      docker.enable = true;
      
      # Local development clusters
      kind.enable = mkIf (cfg.profile == "developer") true;
      k3s.enable = mkIf (cfg.profile == "admin" || cfg.profile == "devops") true;
      
      # GitOps and deployment
      argocd.enable = mkIf cfg.enableGitOps true;
      
      # Production infrastructure
      grafana.enable = mkIf cfg.enableProductionTools true;
    };
  };
}