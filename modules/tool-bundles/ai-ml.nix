{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.aiMl;
in {
  options.modules.toolBundles.aiMl = {
    enable = mkEnableOption "AI and Machine Learning tools bundle";
    
    profile = mkOption {
      type = types.enum [ "researcher" "developer" "selfhosted" "minimal" ];
      default = "developer";
      description = "AI/ML usage profile";
    };
    
    enableLocalModels = mkOption {
      type = types.bool;
      default = cfg.profile != "minimal";
      description = "Enable local LLM hosting (Ollama)";
    };
    
    enableWebInterface = mkOption {
      type = types.bool;
      default = cfg.profile == "researcher" || cfg.profile == "selfhosted";
      description = "Enable web interfaces for AI tools";
    };
    
    enableDevelopmentTools = mkOption {
      type = types.bool;
      default = cfg.profile == "developer" || cfg.profile == "researcher";
      description = "Enable AI development and integration tools";
    };
    
    enableDataScience = mkOption {
      type = types.bool;
      default = cfg.profile == "researcher";
      description = "Enable data science tools (micromamba)";
    };
  };

  config = mkIf cfg.enable {
    modules.tools = {
      # Local model hosting
      ollama.enable = mkIf cfg.enableLocalModels true;
      
      # Web interfaces
      open-webui.enable = mkIf cfg.enableWebInterface true;
      
      # Development integration
      claude-code.enable = mkIf cfg.enableDevelopmentTools true;
      fabric-ai.enable = mkIf cfg.enableDevelopmentTools true;
      
      # Data science environment
      micromamba.enable = mkIf cfg.enableDataScience true;
    };
  };
}