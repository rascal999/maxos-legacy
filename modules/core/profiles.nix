# Profile Management System for MaxOS
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.profiles;
  
  # Define common tool combinations for different user profiles
  profileDefinitions = {
    # Full-stack web developer profile
    fullStackDeveloper = {
      description = "Complete setup for full-stack web development";
      toolBundles = {
        development.enable = true;
        desktop.enable = true;
      };
      tools = {
        # Git workflow
        git.enable = true;
        git.enableCrypt = true;
        git.enableLeaksDetection = true;
        
        # Frontend development
        nodejs.enable = true;
        npm.enable = true;
        
        # Backend development  
        docker.enable = true;
        docker.enableCompose = true;
        docker.enableBuildx = true;
        postgresql.enable = true;
        
        # DevOps and deployment
        k3s.enable = true;
        kind.enable = true;
        
        # Code editors and tools (system-level only)
        chromium.enable = true;
      };
      user = {
        fullName = mkDefault "Full Stack Developer";
        workspaceDirectory = mkDefault "/home/user/projects";
      };
    };
    
    # Security analyst profile
    securityAnalyst = {
      description = "Security analysis and penetration testing tools";
      toolBundles = {
        security.enable = true;
        desktop.enable = true;
      };
      tools = {
        # Network analysis
        wireshark.enable = true;
        nmap.enable = true;
        
        # Vulnerability scanning
        trivy.enable = true;
        semgrep.enable = true;
        
        # Password management
        keepassxc.enable = true;
        
        # Browser for web app testing
        chromium.enable = true;
      };
      security = {
        profile = mkDefault "hardened";
      };
      user = {
        fullName = mkDefault "Security Analyst";
        workspaceDirectory = mkDefault "/home/user/security-workspace";
      };
    };
    
    # Data scientist profile
    dataScientist = {
      description = "Data science and machine learning environment";
      tools = {
        # Python ecosystem
        python.enable = true;
        micromamba.enable = true;
        
        # Data visualization
        grafana.enable = true;
        
        # AI/ML tools
        ollama.enable = true;
        
        # Data storage
        postgresql.enable = true;
        mongodb.enable = true;
        
        # No additional tools needed beyond databases and AI tools
      };
      user = {
        fullName = mkDefault "Data Scientist";
        workspaceDirectory = mkDefault "/home/user/data-projects";
      };
    };
    
    # Home server profile
    homeServer = {
      description = "Self-hosted services and server management";
      toolBundles = {
        server.enable = true;
      };
      tools = {
        # Container orchestration
        docker.enable = true;
        docker.enableCompose = true;
        k3s.enable = true;
        
        # Reverse proxy and networking
        traefik.enable = true;
        wireguard.enable = true;
        blocky.enable = true;
        
        # Monitoring and management
        grafana.enable = true;
        
        # Version control
        forgejo.enable = true;
        forgejo-runner.enable = true;
        
        # Backup and storage
        restic.enable = true;
        
        # Databases
        postgresql.enable = true;
        mongodb.enable = true;
        
        # No additional management tools needed
      };
      user = {
        fullName = mkDefault "Home Server Admin";
        workspaceDirectory = mkDefault "/home/user/server-configs";
      };
    };
    
    # Minimal desktop profile
    minimal = {
      description = "Lightweight desktop setup";
      toolBundles = {
        desktop = {
          enable = true;
          enableAll = false;
          browsers = true;
          terminal = true;
        };
      };
      tools = {
        # Essential tools only (system-level)
        chromium.enable = true;
      };
      user = {
        fullName = mkDefault "Minimal User";
      };
    };
  };

in {
  options.maxos.profiles = {
    # Profile selection
    fullStackDeveloper = mkEnableOption "Full-stack web developer profile";
    securityAnalyst = mkEnableOption "Security analyst profile"; 
    dataScientist = mkEnableOption "Data scientist profile";
    homeServer = mkEnableOption "Home server profile";
    minimal = mkEnableOption "Minimal desktop profile";
    
    # Profile customization
    customizations = mkOption {
      type = types.attrs;
      default = {};
      description = "Profile-specific customizations that override defaults";
      example = {
        fullStackDeveloper = {
          tools.vscode.theme = "dark";
          user.workspaceDirectory = "/custom/path";
        };
      };
    };
  };

  config = mkMerge [
    # Apply each profile when enabled (using explicit config instead of recursive references)
    (mkIf cfg.fullStackDeveloper {
      modules.toolBundles = {
        development.enable = mkDefault true;
        desktop.enable = mkDefault true;
      };
      modules.tools = {
        npm.enable = mkDefault true;
        docker.enable = mkDefault true;
        k3s.enable = mkDefault true;
        kind.enable = mkDefault true;
        chromium.enable = mkDefault true;
        golang.enable = mkDefault true;
      };
      maxos.user = {
        workspaceDirectory = mkDefault "/home/user/projects";
      };
    })
    
    (mkIf cfg.securityAnalyst {
      modules.toolBundles = {
        security.enable = mkDefault true;
        desktop.enable = mkDefault true;
      };
      modules.tools = {
        trivy.enable = mkDefault true;
        semgrep.enable = mkDefault true;
        keepassxc.enable = mkDefault true;
        chromium.enable = mkDefault true;
      };
      maxos.user = {
        workspaceDirectory = mkDefault "/home/user/security-workspace";
      };
    })
    
    (mkIf cfg.dataScientist {
      modules.tools = {
        grafana.enable = mkDefault true;
        mongodb.enable = mkDefault true;
      };
      maxos.user = {
        workspaceDirectory = mkDefault "/home/user/data-projects";
      };
    })
    
    (mkIf cfg.homeServer {
      modules.toolBundles = {
        server.enable = mkDefault true;
      };
      modules.tools = {
        docker.enable = mkDefault true;
        k3s.enable = mkDefault true;
        traefik.enable = mkDefault true;
        grafana.enable = mkDefault true;
        forgejo.enable = mkDefault true;
        restic.enable = mkDefault true;
      };
      maxos.user = {
        workspaceDirectory = mkDefault "/home/user/server-configs";
      };
    })
    
    (mkIf cfg.minimal {
      modules.toolBundles = {
        desktop = {
          enable = mkDefault true;
          enableAll = mkDefault false;
          browsers = mkDefault true;
          terminal = mkDefault true;
        };
      };
      modules.tools = {
        chromium.enable = mkDefault true;
      };
    })
    
    # Profile validation - ensure only one profile is enabled
    {
      assertions = [
        {
          assertion = 
            let enabledProfiles = builtins.length (builtins.filter (x: x) [
              cfg.fullStackDeveloper
              cfg.securityAnalyst  
              cfg.dataScientist
              cfg.homeServer
              cfg.minimal
            ]);
            in enabledProfiles <= 1;
          message = "Only one MaxOS profile can be enabled at a time";
        }
      ];
    }
  ];
}