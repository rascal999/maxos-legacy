{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.genisoimage;
in {
  options.maxos.tools.genisoimage = {
    enable = mkEnableOption "xorriso (ISO 9660 image creation tool)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xorriso
    ];
  };
}