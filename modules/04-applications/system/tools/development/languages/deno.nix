{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.deno;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.deno = {
    enable = mkEnableOption "Deno - secure JavaScript/TypeScript runtime";
    
    package = mkOption {
      type = types.package;
      default = pkgs.deno;
      description = "The Deno package to use";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional Deno-related packages to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Deno requires user module to be enabled";
      }
    ];
  };
}
