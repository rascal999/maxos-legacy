{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.claude-code;

  dependenciesValid =
    config.maxos.user.enable or true;

in {
  options.maxos.tools.claude-code = {
    enable = mkEnableOption "Claude Code";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    home.packages = [ pkgs.claude-code ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "claude-code requires the user module to be enabled";
      }
    ];
  };
}
