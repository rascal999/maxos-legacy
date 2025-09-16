{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.desktop;
in {
  options.modules.toolBundles.desktop = {
    enable = mkEnableOption "Desktop applications bundle";
    
    enableAll = mkOption {
      type = types.bool;
      default = false;
      description = "Enable all desktop applications";
    };
    
    browsers = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable web browsers (Chromium)";
    };
    
    multimedia = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable multimedia tools";
    };
    
    productivity = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable productivity applications (LogSeq)";
    };
    
    utilities = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable desktop utilities (SimpleScreenRecorder, QDirStat)";
    };
    
    terminal = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable terminal applications (Alacritty, Tmux, Zsh)";
    };
    
    remoteAccess = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable remote access tools (Remmina, SSHFS, Mosh)";
    };
  };

  config = mkIf cfg.enable {
    modules.tools = {
      # Web browsers (system-level)
      chromium.enable = mkIf cfg.browsers true;
      
      # Utilities (system-level)
      simplescreenrecorder.enable = mkIf cfg.utilities true;
      qdirstat.enable = mkIf cfg.utilities true;
      
      # Note: The following are handled via home-manager:
      # - Productivity: logseq (home-manager module)
      # - Terminal: alacritty, tmux, zsh (home-manager modules)
      # - Remote access: remmina, sshfs, mosh (home-manager modules)
    };
  };
}