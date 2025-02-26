{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.simplescreenrecorder;
in {
  options.modules.tools.simplescreenrecorder = {
    enable = mkEnableOption "Enable SimpleScreenRecorder";
  };

  config = mkIf cfg.enable {
    # Install SimpleScreenRecorder
    environment.systemPackages = with pkgs; [
      simplescreenrecorder
    ];
  };
}