{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.maxos.tools.karate;
in {
  options.maxos.tools.karate = {
    enable = mkEnableOption "Karate API Testing Framework";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      karate
    ];
  };
}
