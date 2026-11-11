{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.lz4;
in {
  options.maxos.tools.lz4 = {
    enable = mkEnableOption "lz4 compression tool";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lz4
    ];
  };
}
