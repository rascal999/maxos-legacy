{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.syft;
in {
  options.modules.tools.syft = {
    enable = mkEnableOption "Enable Syft SBOM generator";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.syft ];
  };
}