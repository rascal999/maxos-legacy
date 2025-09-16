{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.terminal;
in {
  options.modules.toolBundles.terminal = {
    enable = mkEnableOption "Terminal and CLI tools bundle";
    
    profile = mkOption {
      type = types.enum [ "minimal" "standard" "poweruser" ];
      default = "standard";
      description = "Terminal tools profile level";
    };
    
    enableMultiplexer = mkOption {
      type = types.bool;
      default = cfg.profile != "minimal";
      description = "Enable terminal multiplexer (tmux)";
    };
    
    enableEnhancedShell = mkOption {
      type = types.bool;
      default = true;
      description = "Enable enhanced shell experience (zsh)";
    };
    
    enableDevelopmentEnv = mkOption {
      type = types.bool;
      default = cfg.profile == "poweruser";
      description = "Enable development environment tools";
    };
  };

  config = mkIf cfg.enable {
    modules.tools = {
      # Core terminal
      alacritty.enable = true;
      zsh.enable = mkIf cfg.enableEnhancedShell true;
      
      # Terminal multiplexer
      tmux.enable = mkIf cfg.enableMultiplexer true;
      
      # Development environment
      direnv.enable = mkIf cfg.enableDevelopmentEnv true;
      
      # Input and navigation
      keyd.enable = mkIf (cfg.profile != "minimal") true;
      rofi.enable = mkIf (cfg.profile == "poweruser") true;
    };
  };
}