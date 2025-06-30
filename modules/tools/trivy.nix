{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.trivy;
in {
  options.modules.tools.trivy = {
    enable = mkEnableOption "Enable Trivy vulnerability scanner";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.trivy ];
  };
}