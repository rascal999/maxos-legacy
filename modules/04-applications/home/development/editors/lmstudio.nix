{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.lmstudio;

  dependenciesValid =
    config.maxos.user.enable or true;

in {
  options.maxos.tools.lmstudio = {
    enable = mkEnableOption "LM Studio — local LLM GUI";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    home.packages = [ pkgs.lmstudio ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "lmstudio requires the user module to be enabled";
      }
    ];
  };
}
