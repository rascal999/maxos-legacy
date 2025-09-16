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
    modules.tools = {
      # Kubernetes (k3s and skaffold are system-level, argocd is home-manager)
      k3s.enable = mkIf cfg.kubernetes true;
      skaffold.enable = mkIf cfg.kubernetes true;
      
      # Networking
      traefik.enable = mkIf cfg.networking true;
      blocky.enable = mkIf cfg.networking true;
      # wireguard.enable = mkIf cfg.networking true;  # Needs proper module format
      
      # Databases
      mongodb.enable = mkIf cfg.databases true;
      
      # Monitoring
      grafana.enable = mkIf cfg.monitoring true;
      
      # Version control
      forgejo.enable = mkIf cfg.vcs true;
      forgejo-runner.enable = mkIf cfg.vcs true;
      forgejo-cli.enable = mkIf cfg.vcs true;
      
      # Backup
      restic.enable = mkIf cfg.backup true;
      
      # Note: QEMU module needs to be converted to proper module format
      # qemu.enable = mkIf cfg.virtualization true;
    };
  };
}