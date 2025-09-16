{ config, lib, ... }:

# Home server profile for self-hosted services and infrastructure

with lib;

{
  imports = [
    # Core bundles for server
    ../tool-bundles/server-stack.nix
    ../tool-bundles/devops.nix
    ../tool-bundles/ai-ml.nix
    ../security/default.nix
  ];

  # Enable tool bundles with server-focused profiles
  modules.toolBundles = {
    serverStack = {
      enable = mkDefault true;
      profile = mkDefault "standard";
      enableInfrastructure = mkDefault true;
      enableMonitoring = mkDefault true;
      enableBackup = mkDefault true;
    };
    
    devops = {
      enable = mkDefault true;
      profile = mkDefault "cicd";
      enableContainerPlatform = mkDefault true;
      enableCICD = mkDefault true;
      enableMonitoring = mkDefault true;
      enableSecurityScanning = mkDefault true;
    };
    
    aiMl = {
      enable = mkDefault true;
      profile = mkDefault "selfhosted";
      enableLocalModels = mkDefault true;
      enableWebInterface = mkDefault true;
    };
  };

  # Server-specific tools
  modules.tools = {
    # Infrastructure
    docker.enable = mkDefault true;
    k3s.enable = mkDefault true;
    blocky.enable = mkDefault true;
    wireguard.enable = mkDefault true;
    
    # Monitoring and management
    grafana.enable = mkDefault true;
    argocd.enable = mkDefault true;
    
    # AI/ML self-hosting
    ollama.enable = mkDefault true;
    open-webui.enable = mkDefault true;
    
    # Backup and security
    restic.enable = mkDefault true;
    trivy.enable = mkDefault true;
  };

  # Security hardening
  security = {
    enable = mkDefault true;
    sshHardening = mkDefault true;
    firewallEnable = mkDefault true;
    enableAudit = mkDefault true;
    strongPasswords = mkDefault true;
  };

  # User configuration
  maxos.user = {
    workspaceDirectory = mkDefault "/home/user/server-configs";
  };

  # Server-specific system configuration
  services.openssh = {
    enable = mkDefault true;
    settings = {
      PasswordAuthentication = mkDefault false;
      PermitRootLogin = mkDefault "no";
    };
  };
}