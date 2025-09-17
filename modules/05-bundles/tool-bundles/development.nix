{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.development;
in {
  options.modules.toolBundles.development = {
    enable = mkEnableOption "Development tools bundle";
    
    enableAll = mkOption {
      type = types.bool;
      default = false;
      description = "Enable all development tools";
    };
    
    git = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable Git tools (git-crypt, gitleaks)";
    };
    
    nodejs = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable Node.js and npm";
    };
    
    golang = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable Go development tools";
    };
    
    editors = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable code editors (VSCode)";
    };
    
    containerization = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable containerization tools (Docker, Kind)";
    };
  };

  config = mkIf cfg.enable {
    maxos.tools = {
      # Core development tools (git, neovim, ripgrep, fd, jq, tree, pwgen)
      development-core.enable = mkIf cfg.enableAll true;
      
      # Java development tools (jdk, maven, gradle)
      java.enable = mkIf cfg.enableAll true;
      
      # Git tools (gitleaks is system-level, git-crypt is home-manager)
      gitleaks.enable = mkIf cfg.git true;
      
      # Node.js development (system-level)
      npm.enable = mkIf cfg.nodejs true;
      
      # Go development (system-level)
      golang.enable = mkIf cfg.golang true;
      
      # Containerization (system-level)
      docker.enable = mkIf cfg.containerization true;
      
      # Note: The following are handled via home-manager:
      # - Git tools: git-crypt (home-manager module)
      # - Editors: vscode (home-manager module)
    };
  };
}