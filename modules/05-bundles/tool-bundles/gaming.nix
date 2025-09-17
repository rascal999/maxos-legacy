{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.gaming;
in {
  options.modules.toolBundles.gaming = {
    enable = mkEnableOption "Gaming tools bundle";
    
    profile = mkOption {
      type = types.enum [ "casual" "enthusiast" "streamer" ];
      default = "casual";
      description = "Gaming profile level";
    };
    
    enableSteam = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Steam gaming platform";
    };
    
    enableRecording = mkOption {
      type = types.bool;
      default = cfg.profile == "streamer" || cfg.profile == "enthusiast";
      description = "Enable game recording and streaming tools";
    };
    
    enableOptimization = mkOption {
      type = types.bool;
      default = cfg.profile != "casual";
      description = "Enable gaming optimization tools";
    };
  };

  config = mkIf cfg.enable {
    maxos.tools = {
      # Gaming platforms
      steam.enable = mkIf cfg.enableSteam true;
      
      # Recording and streaming
      simplescreenrecorder.enable = mkIf cfg.enableRecording true;
      
      # Essential for all gaming profiles
      chromium.enable = true;  # For web-based games and game launchers
    };
  };
}