{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.webdev;
in {
  options.modules.toolBundles.webdev = {
    enable = mkEnableOption "Web development tools bundle";
    
    profile = mkOption {
      type = types.enum [ "frontend" "backend" "fullstack" "minimal" ];
      default = "fullstack";
      description = "Web development profile";
    };
    
    enableFrontend = mkOption {
      type = types.bool;
      default = cfg.profile == "frontend" || cfg.profile == "fullstack";
      description = "Enable frontend development tools";
    };
    
    enableBackend = mkOption {
      type = types.bool;
      default = cfg.profile == "backend" || cfg.profile == "fullstack";
      description = "Enable backend development tools";
    };
    
    enableContainerization = mkOption {
      type = types.bool;
      default = cfg.profile == "fullstack" || cfg.profile == "backend";
      description = "Enable containerization for web apps";
    };
    
    enableTesting = mkOption {
      type = types.bool;
      default = cfg.profile != "minimal";
      description = "Enable API testing tools";
    };
  };

  config = mkIf cfg.enable {
    modules.tools = {
      # Frontend development
      npm.enable = mkIf cfg.enableFrontend true;
      vscode.enable = mkIf cfg.enableFrontend true;
      chromium.enable = mkIf cfg.enableFrontend true;
      
      # Backend development
      docker.enable = mkIf cfg.enableBackend true;
      
      # API development and testing
      postman.enable = mkIf cfg.enableTesting true;
      
      # Infrastructure (fullstack)
      # Infrastructure tools would go here
      
      # Containerization
      docker.enable = mkIf cfg.enableContainerization true;
    };
  };
}