{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.profiles.comprehensiveWorkstation;
in {
  options.maxos.profiles.comprehensiveWorkstation = {
    enable = mkEnableOption "Comprehensive workstation profile (development + gaming + security + multimedia)";
    
    profile = mkOption {
      type = types.enum [ "minimal" "standard" "full" "ultimate" ];
      default = "full";
      description = "Rig workstation profile level";
    };
    
    enableDevelopment = mkOption {
      type = types.bool;
      default = true;
      description = "Enable development tools and environments";
    };
    
    enableGaming = mkOption {
      type = types.bool;
      default = cfg.profile != "minimal";
      description = "Enable gaming tools and platforms";
    };
    
    enableSecurity = mkOption {
      type = types.bool;
      default = true;
      description = "Enable security scanning and crypto tools";
    };
    
    enableMultimedia = mkOption {
      type = types.bool;
      default = cfg.profile != "minimal";
      description = "Enable multimedia creation and editing tools";
    };
    
    enableInfrastructure = mkOption {
      type = types.bool;
      default = cfg.profile == "full" || cfg.profile == "ultimate";
      description = "Enable infrastructure and DevOps tools";
    };
  };

  config = mkIf cfg.enable {
    # Enable comprehensive tool bundles
    modules.toolBundles = {
      # Core workstation (includes desktop + development)
      workstation = {
        enable = true;
        profile = if cfg.profile == "ultimate" then "full" else "standard";
        enableDesktop = true;
        enableDevelopment = cfg.enableDevelopment;
        enableProductivity = true;
      };
      
      # Security tools
      security = {
        enable = cfg.enableSecurity;
        enableAll = cfg.profile == "full" || cfg.profile == "ultimate";
        scanners = true;
        crypto = true;
        passwordManagement = true;
      };
      
      # Gaming bundle
      gaming = {
        enable = cfg.enableGaming;
        profile = if cfg.profile == "ultimate" then "streamer" else "enthusiast";
        enableSteam = true;
        enableRecording = cfg.profile != "minimal";
      };
      
      # Development tools (enhanced)
      development = {
        enable = cfg.enableDevelopment;
        enableAll = cfg.profile == "full" || cfg.profile == "ultimate";
        git = true;
        nodejs = true;
        golang = true;
        editors = true;
        containerization = true;
      };
      
      # Desktop applications (enhanced)
      desktop = {
        enable = true;
        enableAll = cfg.profile == "full" || cfg.profile == "ultimate";
        browsers = true;
        multimedia = cfg.enableMultimedia;
        productivity = true;
        utilities = true;
        terminal = true;
        remoteAccess = true;
      };
      
      # Infrastructure tools
      kubernetes = mkIf cfg.enableInfrastructure {
        enable = true;
      };
      
      devops = mkIf cfg.enableInfrastructure {
        enable = true;
      };
    };

    # Additional individual tools not covered by bundles
    maxos.tools = {
      # Infrastructure services - use MaxOS k3s wrapper (Layer 3)
      k3s = mkIf cfg.enableInfrastructure {
        enable = true;
        role = "server";
        extraFlags = [
          "--disable-cloud-controller"
        ];
      };
      # AI/ML tools
      fabric-ai.enable = cfg.profile == "full" || cfg.profile == "ultimate";
      
      blocky.enable = mkDefault cfg.enableInfrastructure;
      
      # Backup and data management
      restic = {
        enable = mkDefault true;
        hostSubdir = mkDefault "workstation";
        useSopsSecrets = mkDefault true;
      };
      
      # Additional browsers
      brave.enable = mkDefault true;
      tor-browser.enable = mkDefault cfg.enableSecurity;
      
      # Data analysis tools
      linuxquota = mkIf (cfg.profile == "full" || cfg.profile == "ultimate") {
        enable = mkDefault true;
        enableUserQuotas = mkDefault true;
        enableGroupQuotas = mkDefault true;
      };
      
      # Networking tools
      mosh.enable = mkDefault true;
      
      # Kubernetes tools
      argocd.enable = mkDefault cfg.enableInfrastructure;
      
      # AI tools (selective enabling)
      grafana.enable = mkDefault false;
      ollama.enable = mkDefault false;
      open-webui.enable = mkDefault false;
    };
  };
}