{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.server;
in {
  options.modules.toolBundles.server = {
    enable = mkEnableOption "Server tools and services bundle";
    
    enableAll = mkOption {
      type = types.bool;
      default = false;
      description = "Enable all server tools";
    };
    
    kubernetes = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable Kubernetes tools (K3s, ArgoCD, Skaffold)";
    };
    
    networking = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable networking tools (Traefik, Blocky, WireGuard)";
    };
    
    databases = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable databases (MongoDB)";
    };
    
    monitoring = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable monitoring tools (Grafana)";
    };
    
    vcs = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable version control servers (Forgejo)";
    };
    
    backup = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable backup solutions (Restic)";
    };
    
    virtualization = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable virtualization (QEMU)";
    };
  };

  config = mkIf cfg.enable {
    maxos.tools = {
      # Kubernetes
      k3s.enable = mkIf cfg.kubernetes true;
      argocd.enable = mkIf cfg.kubernetes true;
      
      # Networking
      blocky.enable = mkIf cfg.networking true;
      wireguard.enable = mkIf cfg.networking true;
      
      # Monitoring
      grafana.enable = mkIf cfg.monitoring true;
      
      # Backup
      restic.enable = mkIf cfg.backup true;
      
      # Note: qemu module needs proper module format conversion
      # qemu.enable = mkIf cfg.virtualization true;
    };
  };
}