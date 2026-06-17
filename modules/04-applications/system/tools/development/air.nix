{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.air;
in {
  options.maxos.tools.air = {
    enable = mkEnableOption "Air Go live-reload tool";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      air
    ];
  };
}
