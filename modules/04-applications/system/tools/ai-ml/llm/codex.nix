{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.codex;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.codex = {
    enable = mkEnableOption "OpenAI Codex CLI tool";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      codex
    ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "Codex requires user module to be enabled";
      }
    ];
  };
}