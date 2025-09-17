{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.qdirstat;
in {
  options.maxos.tools.qdirstat = {
    enable = mkEnableOption "QDirStat (Qt-based directory statistics tool)";
  };

  config = mkIf cfg.enable {
    # Install QDirStat package
    environment.systemPackages = with pkgs; [
      qdirstat
    ];
  };
}