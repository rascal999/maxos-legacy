{ config, lib, pkgs, ... }:

# Pre-configured usage patterns for common MaxOS setups

with lib;

let
  cfg = config.modules.toolBundles.usagePatterns;
  
  # Define usage patterns as attribute sets
  patterns = {
    # Developer workstation with full-stack capabilities and AI assistance
    developer-workstation = {
      description = "Full-stack development with AI assistance and containerization";
      bundles = {
        workstation = { enable = true; profile = "full"; };
        aiMl = { enable = true; profile = "developer"; };
        webdev = { enable = true; profile = "fullstack"; };
        kubernetes = { enable = true; profile = "developer"; };
        terminal = { enable = true; profile = "poweruser"; };
        devops = { enable = true; profile = "core"; };
      };
      hardware = {
        desktop.enable = true;
        desktop.performance.governor = "performance";
        desktop.graphics.enable = true;
      };
    };
    
    # Security researcher with analysis tools and AI for research
    security-researcher = {
      description = "Security analysis, penetration testing, and threat research";
      bundles = {
        workstation = { enable = true; profile = "standard"; };
        security = { enable = true; profile = "analyst"; };
        aiMl = { enable = true; profile = "researcher"; };
        terminal = { enable = true; profile = "poweruser"; };
        remoteWork = { enable = true; profile = "secure"; };
      };
      hardware = {
        desktop.enable = true;
        desktop.performance.governor = "performance";
      };
    };
    
    # DevOps engineer focused on infrastructure and automation
    devops-engineer = {
      description = "Infrastructure automation, CI/CD, and container orchestration";
      bundles = {
        serverStack = { enable = true; profile = "enterprise"; };
        devops = { enable = true; profile = "complete"; };
        kubernetes = { enable = true; profile = "admin"; };
        security = { enable = true; profile = "server"; };
        terminal = { enable = true; profile = "poweruser"; };
      };
      hardware = {
        server.enable = true;
        server.performance.governor = "performance";
        server.network.optimizeForThroughput = true;
      };
    };
    
    # Content creator for streaming and multimedia production
    content-creator = {
      description = "Content creation, streaming, and multimedia production";
      bundles = {
        workstation = { enable = true; profile = "full"; };
        contentCreation = { enable = true; profile = "streamer"; };
        gaming = { enable = true; profile = "streamer"; };
        aiMl = { enable = true; profile = "developer"; };
        terminal = { enable = true; profile = "standard"; };
      };
      hardware = {
        desktop.enable = true;
        desktop.performance.governor = "performance";
        desktop.graphics.enable = true;
        desktop.audio.enable = true;
        desktop.audio.lowLatency = true;
      };
    };
    
    # Remote worker with secure connectivity and collaboration tools
    remote-worker = {
      description = "Secure remote work with VPN, collaboration, and productivity tools";
      bundles = {
        workstation = { enable = true; profile = "standard"; };
        remoteWork = { enable = true; profile = "enhanced"; };
        aiMl = { enable = true; profile = "developer"; };
        security = { enable = true; profile = "basic"; };
        terminal = { enable = true; profile = "standard"; };
      };
      hardware = {
        laptop.enable = true;
        laptop.powerManagement.enable = true;
        laptop.wireless.enable = true;
      };
    };
    
    # Home server for self-hosted services and AI
    home-server = {
      description = "Self-hosted services, AI platforms, and infrastructure management";
      bundles = {
        serverStack = { enable = true; profile = "standard"; };
        aiMl = { enable = true; profile = "selfhosted"; };
        devops = { enable = true; profile = "cicd"; };
        security = { enable = true; profile = "server"; };
        terminal = { enable = true; profile = "standard"; };
      };
      hardware = {
        server.enable = true;
        server.performance.governor = "performance";
        server.network.enableBBR = true;
        server.monitoring.enable = true;
      };
    };
    
    # Gaming rig for high-performance gaming and content creation
    gaming-rig = {
      description = "High-performance gaming with streaming and content creation capabilities";
      bundles = {
        workstation = { enable = true; profile = "full"; };
        gaming = { enable = true; profile = "enthusiast"; };
        contentCreation = { enable = true; profile = "streamer"; };
        terminal = { enable = true; profile = "standard"; };
      };
      hardware = {
        desktop.enable = true;
        desktop.performance.governor = "performance";
        desktop.performance.highPerformance = true;
        desktop.graphics.enable = true;
        desktop.audio.enable = true;
      };
    };
    
    # AI researcher for machine learning and data science
    ai-researcher = {
      description = "AI research, data science, and machine learning development";
      bundles = {
        workstation = { enable = true; profile = "full"; };
        aiMl = { enable = true; profile = "researcher"; };
        webdev = { enable = true; profile = "backend"; };
        terminal = { enable = true; profile = "poweruser"; };
        devops = { enable = true; profile = "core"; };
      };
      hardware = {
        desktop.enable = true;
        desktop.performance.governor = "performance";
        desktop.graphics.enable = true; # For GPU acceleration
      };
    };
    
    # Minimal desktop for lightweight systems
    minimal-desktop = {
      description = "Lightweight desktop for basic productivity and web browsing";
      bundles = {
        terminal = { enable = true; profile = "minimal"; };
        desktop = { 
          enable = true; 
          enableAll = false;
          browsers = true;
          terminal = true;
        };
      };
      hardware = {
        laptop.enable = true;
        laptop.powerManagement.enable = true;
      };
    };
  };
  
in {
  options.modules.toolBundles.usagePatterns = {
    enable = mkEnableOption "Pre-configured usage patterns";
    
    preset = mkOption {
      type = types.enum (builtins.attrNames patterns);
      description = "Pre-configured usage pattern preset";
      example = "developer-workstation";
    };
    
    customizations = mkOption {
      type = types.attrs;
      default = {};
      description = "Override settings for the selected pattern";
      example = {
        aiMl.profile = "researcher";
        hardware.desktop.graphics.nvidia = true;
      };
    };
    
    listPatterns = mkOption {
      type = types.bool;
      default = false;
      description = "Generate a list of available patterns (for documentation)";
    };
  };

  config = mkMerge [
    # Apply selected pattern
    (mkIf cfg.enable (
      let
        selectedPattern = patterns.${cfg.preset};
        
        # Apply bundle configuration with customizations
        bundleConfig = mkMerge (mapAttrsToList (bundleName: bundleSettings:
          let
            customBundleSettings = cfg.customizations.${bundleName} or {};
            mergedSettings = recursiveUpdate bundleSettings customBundleSettings;
          in
          { modules.toolBundles.${bundleName} = mergedSettings; }
        ) selectedPattern.bundles);
        
        # Apply hardware configuration with customizations
        hardwareConfig = mkMerge (mapAttrsToList (hwType: hwSettings:
          let
            customHwSettings = cfg.customizations.hardware.${hwType} or {};
            mergedHwSettings = recursiveUpdate hwSettings customHwSettings;
          in
          { maxos.hardware.${hwType} = mergedHwSettings; }
        ) selectedPattern.hardware);
        
      in mkMerge [
        bundleConfig
        hardwareConfig
      ]
    ))
    
    # Generate pattern documentation
    (mkIf cfg.listPatterns {
      system.build.usagePatternsList = pkgs.writeText "usage-patterns-list.md" ''
        # MaxOS Usage Patterns
        
        Available pre-configured patterns:
        
        ${concatStringsSep "\n\n" (mapAttrsToList (name: pattern: ''
          ## ${name}
          ${pattern.description}
          
          **Bundles:**
          ${concatStringsSep "\n" (mapAttrsToList (bundleName: settings: 
            "- ${bundleName}: ${if settings ? profile then settings.profile else "enabled"}"
          ) pattern.bundles)}
          
          **Hardware:**
          ${concatStringsSep "\n" (mapAttrsToList (hwName: _: 
            "- ${hwName} optimizations"
          ) pattern.hardware)}
        '') patterns)}
        
        ## Usage
        
        To use a pattern in your host configuration:
        
        ```nix
        {
          modules.toolBundles.usagePatterns = {
            enable = true;
            preset = "developer-workstation";
            
            # Optional customizations
            customizations = {
              aiMl.profile = "researcher";
              hardware.desktop.graphics.nvidia = true;
            };
          };
        }
        ```
      '';
    })
  ];
}