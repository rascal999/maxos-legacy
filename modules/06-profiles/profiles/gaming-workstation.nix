{ config, lib, ... }:

# Gaming workstation profile for high-performance desktop with gaming, development, and content creation capabilities

with lib;

{
  imports = [
    # Core bundles for gaming workstation
    ../../05-bundles/tool-bundles/workstation.nix
    ../../05-bundles/tool-bundles/gaming.nix
    ../../05-bundles/tool-bundles/content-creation.nix
    ../../05-bundles/tool-bundles/ai-ml.nix
    # Browser tools configured via bundles
  ];

  # Enable tool bundles with appropriate profiles
  modules.toolBundles = {
    workstation = {
      enable = mkDefault true;
      profile = mkDefault "full";
      enableDesktop = mkDefault true;
      enableDevelopment = mkDefault true;
      enableProductivity = mkDefault true;
    };
    
    gaming = {
      enable = mkDefault true;
      profile = mkDefault "enthusiast";
      enableSteam = mkDefault true;
      enableRecording = mkDefault true;
      enableOptimization = mkDefault true;
    };
    
    contentCreation = {
      enable = mkDefault true;
      profile = mkDefault "streamer";
      enableScreenCapture = mkDefault true;
      enableGaming = mkDefault true;
      enableDockerGraphics = mkDefault true;
    };
    
    aiMl = {
      enable = mkDefault true;
      profile = mkDefault "developer";
      enableLocalModels = mkDefault true;
      enableDevelopmentTools = mkDefault true;
    };
  };

  # Gaming workstation specific configuration
  maxos.tools = {
    # Enhanced development setup
    docker.enable = mkDefault true;
    chromium.enable = mkDefault true;
    keepassxc.enable = mkDefault true;
    
    # Gaming and content creation
    steam.enable = mkDefault true;
    simplescreenrecorder.enable = mkDefault true;
    
    # AI/ML tools
    ollama.enable = mkDefault true;
    open-webui.enable = mkDefault true;
  };

  # User configuration
  maxos.user = {
    workspaceDirectory = mkDefault "/home/user/projects";
  };

  # Hardware optimizations
  hardware = {
    graphics = {
      enable = mkDefault true;
      # driSupport is deprecated and automatically enabled
    };
  };
}