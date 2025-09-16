{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.workstation;
in {
  options.modules.toolBundles.workstation = {
    enable = mkEnableOption "Essential workstation bundle (desktop + development)";
    
    profile = mkOption {
      type = types.enum [ "minimal" "standard" "full" ];
      default = "standard";
      description = "Workstation profile level";
    };
    
    enableDesktop = mkOption {
      type = types.bool;
      default = true;
      description = "Enable desktop applications";
    };
    
    enableDevelopment = mkOption {
      type = types.bool;
      default = true;
      description = "Enable development tools";
    };
    
    enableProductivity = mkOption {
      type = types.bool;
      default = cfg.profile != "minimal";
      description = "Enable productivity applications";
    };
  };

  config = mkIf cfg.enable {
    # Enable component bundles
    modules.toolBundles = {
      terminal.enable = true;
      desktop.enable = cfg.enableDesktop;
      development.enable = cfg.enableDevelopment;
    };

    modules.tools = {
      # Core desktop essentials
      chromium.enable = mkIf cfg.enableDesktop true;
      keepassxc.enable = mkIf cfg.enableDesktop true;
      # Note: syncthing needs proper module format
      # syncthing.enable = mkIf cfg.enableDesktop true;
      
      # Development essentials (system-level)
      docker.enable = mkIf cfg.enableDevelopment true;
      
      # Note: The following are handled via home-manager:
      # - Editor: vscode (home-manager module)
      # - Security: git-crypt (home-manager module)
      # - Productivity: logseq (home-manager module)
      # - Remote: remmina (home-manager module)
      
      # Full profile additions
      simplescreenrecorder.enable = mkIf (cfg.profile == "full") true;
      qdirstat.enable = mkIf (cfg.profile == "full") true;
      postman.enable = mkIf (cfg.profile == "full") true;
    };
  };
}