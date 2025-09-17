{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.simplescreenrecorder;
in {
  options.maxos.tools.simplescreenrecorder = {
    enable = mkEnableOption "Enable SimpleScreenRecorder";
  };

  config = mkIf cfg.enable {
    # Install SimpleScreenRecorder
    environment.systemPackages = with pkgs; [
      simplescreenrecorder
    ];
  };
}