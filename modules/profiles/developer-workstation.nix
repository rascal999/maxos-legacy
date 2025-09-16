{ config, lib, ... }:

# Developer workstation profile focused on software development with AI assistance

with lib;

{
  imports = [
    # Core bundles for development
    ../tool-bundles/workstation.nix
    ../tool-bundles/webdev.nix
    ../tool-bundles/kubernetes.nix
    ../tool-bundles/ai-ml.nix
    ../tool-bundles/devops.nix
  ];

  # Enable tool bundles with development-focused profiles
  modules.toolBundles = {
    workstation = {
      enable = mkDefault true;
      profile = mkDefault "standard";
      enableDesktop = mkDefault true;
      enableDevelopment = mkDefault true;
      enableProductivity = mkDefault true;
    };
    
    webdev = {
      enable = mkDefault true;
      profile = mkDefault "fullstack";
      enableFrontend = mkDefault true;
      enableBackend = mkDefault true;
      enableContainerization = mkDefault true;
      enableTesting = mkDefault true;
    };
    
    kubernetes = {
      enable = mkDefault true;
      profile = mkDefault "developer";
      enableLocalCluster = mkDefault true;
      enableDevelopmentWorkflow = mkDefault true;
    };
    
    aiMl = {
      enable = mkDefault true;
      profile = mkDefault "developer";
      enableLocalModels = mkDefault true;
      enableDevelopmentTools = mkDefault true;
    };
    
    devops = {
      enable = mkDefault true;
      profile = mkDefault "core";
      enableContainerPlatform = mkDefault true;
      enableSecurityScanning = mkDefault true;
    };
  };

  # Developer-specific tools
  modules.tools = {
    # Core development
    docker.enable = mkDefault true;
    kind.enable = mkDefault true;
    npm.enable = mkDefault true;
    golang.enable = mkDefault true;
    
    # Security and analysis
    trivy.enable = mkDefault true;
    semgrep.enable = mkDefault true;
    
    # AI assistance
    ollama.enable = mkDefault true;
    
    # Essential desktop
    chromium.enable = mkDefault true;
    keepassxc.enable = mkDefault true;
  };

  # User configuration
  maxos.user = {
    workspaceDirectory = mkDefault "/home/user/projects";
  };
}