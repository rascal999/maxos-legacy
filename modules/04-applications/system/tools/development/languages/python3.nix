{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.python3;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.python3 = {
    enable = mkEnableOption "Python 3 programming language support";
    
    package = mkOption {
      type = types.package;
      default = pkgs.python3;
      description = "The Python 3 package to use";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional Python-related packages to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Python 3 requires user module to be enabled";
      }
    ];
  };
}
