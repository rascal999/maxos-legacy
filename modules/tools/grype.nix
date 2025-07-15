{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.grype;
in {
  options.modules.tools.grype = {
    enable = mkEnableOption "Enable Grype vulnerability scanner";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.grype ];
  };
}