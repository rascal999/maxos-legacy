{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.sqlite;
in {
  options.maxos.tools.sqlite = {
    enable = mkEnableOption "SQLite database engine and command-line shell";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sqlite
    ];
  };
}
