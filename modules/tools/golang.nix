{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.golang;
in {
  options.modules.tools.golang = {
    enable = mkEnableOption "Enable Golang support";
    
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

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    
    # Set up GOPATH in the environment
    environment.variables = {
      GOPATH = "$HOME/go";
      PATH = [ "$GOPATH/bin" ];
    };
  };
}