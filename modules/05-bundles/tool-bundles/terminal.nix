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
    maxos.tools = {
      # System-level terminal tools
      keyd.enable = mkIf (cfg.profile != "minimal") true;
      
      # Note: The following are handled via home-manager:
      # - Terminal: alacritty (home-manager module)
      # - Shell: zsh (home-manager module) 
      # - Multiplexer: tmux (home-manager module)
      # - Environment: direnv (home-manager module)
      # - Launcher: rofi (home-manager module)
    };
  };
}