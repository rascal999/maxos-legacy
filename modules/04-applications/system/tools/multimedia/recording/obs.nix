{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.obs;
in {
  options.maxos.tools.obs = {
    enable = mkEnableOption "Enable OBS Studio (Open Broadcaster Software)";
    
    enablePlugins = mkOption {
      type = types.bool;
      default = true;
      description = "Enable common OBS plugins";
    };
    
    enableVirtualCamera = mkOption {
      type = types.bool;
      default = true;
      description = "Enable OBS virtual camera support";
    };
  };

  config = mkIf cfg.enable {
    # Install OBS Studio with plugins
    environment.systemPackages = with pkgs; [
      obs-studio
    ] ++ optionals cfg.enablePlugins [
      obs-studio-plugins.obs-backgroundremoval
      obs-studio-plugins.obs-pipewire-audio-capture
      obs-studio-plugins.wlrobs
    ];
    
    # Enable v4l2loopback kernel module for virtual camera
    boot.extraModulePackages = mkIf cfg.enableVirtualCamera [
      config.boot.kernelPackages.v4l2loopback
    ];
    
    boot.kernelModules = mkIf cfg.enableVirtualCamera [
      "v4l2loopback"
    ];
    
    boot.extraModprobeConfig = mkIf cfg.enableVirtualCamera ''
      options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
    '';
  };
}