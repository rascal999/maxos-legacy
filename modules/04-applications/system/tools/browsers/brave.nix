{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.brave;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.brave = {
    enable = mkEnableOption "Brave web browser";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      brave
    ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Brave requires user module";
      }
    ];
  };
}