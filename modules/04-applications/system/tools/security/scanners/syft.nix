{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.syft;
in {
  options.maxos.tools.syft = {
    enable = mkEnableOption "Enable Syft SBOM generator";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.syft ];
  };
}