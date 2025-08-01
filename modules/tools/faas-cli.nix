{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.faas-cli;
in {
  options.modules.tools.faas-cli = {
    enable = mkEnableOption "Enable faas-cli (OpenFaaS CLI)";
    
    package = mkOption {
      type = types.package;
      default = pkgs.faas-cli;
      description = "The faas-cli package to use";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional OpenFaaS-related packages to install";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
  };
}