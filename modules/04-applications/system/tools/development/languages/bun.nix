{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.bun;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.bun = {
    enable = mkEnableOption "Bun - fast JavaScript runtime and toolkit";
    
    package = mkOption {
      type = types.package;
      default = pkgs.bun;
      description = "The Bun package to use";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional Bun-related packages to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Bun requires user module to be enabled";
      }
    ];
  };
}