{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.qdirstat;
in {
  options.modules.tools.qdirstat = {
    enable = mkEnableOption "QDirStat (Qt-based directory statistics tool)";
  };

  config = mkIf cfg.enable {
    # Install QDirStat package
    environment.systemPackages = with pkgs; [
      qdirstat
    ];
  };
}