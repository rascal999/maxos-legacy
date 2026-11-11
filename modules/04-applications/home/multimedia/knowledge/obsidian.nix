{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.obsidian;
in {
  options.maxos.tools.obsidian = {
    enable = mkEnableOption "Obsidian knowledge management application";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.obsidian ];
  };
}
