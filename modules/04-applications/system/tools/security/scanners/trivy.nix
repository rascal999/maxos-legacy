{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.trivy;
in {
  options.maxos.tools.trivy = {
    enable = mkEnableOption "Enable Trivy vulnerability scanner";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.trivy ];
  };
}