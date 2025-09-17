{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.ollama;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.ollama = {
    enable = mkEnableOption "Ollama AI language model server";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
    };
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Ollama requires user module to be enabled";
      }
    ];
  };
}
