{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.grype;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.grype = {
    enable = mkEnableOption "Grype vulnerability scanner";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ pkgs.grype ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Grype requires user module to be enabled";
      }
    ];
  };
}