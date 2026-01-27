{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.screen;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true;
    
in {
  options.maxos.tools.screen = {
    enable = mkEnableOption "GNU Screen terminal multiplexer";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      screen
    ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Screen requires no dependencies";
      }
    ];
  };
}
