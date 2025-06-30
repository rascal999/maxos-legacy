{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.semgrep;
in {
  options.modules.tools.semgrep = {
    enable = mkEnableOption "Enable Semgrep static analysis tool";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.semgrep ];
  };
}