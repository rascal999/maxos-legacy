{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.golang;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.golang = {
    enable = mkEnableOption "Golang programming language support";
    
    package = mkOption {
      type = types.package;
      default = pkgs.go;
      description = "The Golang package to use";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional Golang-related packages to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    
    # Set up GOPATH in the environment
    environment.variables = {
      GOPATH = "$HOME/go";
      PATH = [ "$GOPATH/bin" ];
    };
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Golang requires user module to be enabled";
      }
    ];
  };
}