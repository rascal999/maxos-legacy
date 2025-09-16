{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.contentCreation;
in {
  options.modules.toolBundles.contentCreation = {
    enable = mkEnableOption "Content creation tools bundle";
    
    profile = mkOption {
      type = types.enum [ "writer" "streamer" "gamer" "multimedia" ];
      default = "writer";
      description = "Content creation profile";
    };
    
    enableScreenCapture = mkOption {
      type = types.bool;
      default = cfg.profile == "streamer" || cfg.profile == "multimedia";
      description = "Enable screen recording and capture tools";
    };
    
    enableGaming = mkOption {
      type = types.bool;
      default = cfg.profile == "gamer" || cfg.profile == "streamer";
      description = "Enable gaming platforms and tools";
    };
    
    enableWriting = mkOption {
      type = types.bool;
      default = cfg.profile == "writer" || cfg.profile == "multimedia";
      description = "Enable writing and note-taking tools";
    };
    
    enableDockerGraphics = mkOption {
      type = types.bool;
      default = cfg.profile == "streamer";
      description = "Enable Docker with graphics support";
    };
  };

  config = mkIf cfg.enable {
    modules.tools = {
      # Screen capture and recording
      simplescreenrecorder.enable = mkIf cfg.enableScreenCapture true;
      
      # Gaming
      steam.enable = mkIf cfg.enableGaming true;
      
      # Writing and productivity
      logseq.enable = mkIf cfg.enableWriting true;
      firefox.enable = mkIf cfg.enableWriting true;
      syncthing.enable = mkIf cfg.enableWriting true;
      
      # Graphics and multimedia support
      x11-docker.enable = mkIf cfg.enableDockerGraphics true;
      pulseaudio-docker.enable = mkIf cfg.enableDockerGraphics true;
      
      # Essential browser for all profiles
      chromium.enable = true;
    };
  };
}