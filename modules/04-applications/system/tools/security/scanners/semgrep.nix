{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.semgrep;
in {
  options.maxos.tools.semgrep = {
    enable = mkEnableOption "Enable Semgrep static analysis tool";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.semgrep ];
  };
}