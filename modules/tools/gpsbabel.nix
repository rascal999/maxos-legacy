{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.gpsbabel;
in {
  options.modules.tools.gpsbabel = {
    enable = mkEnableOption "Enable GPSBabel GPS data conversion tool";
    
    package = mkOption {
      type = types.package;
      default = pkgs.gpsbabel;
      description = "The GPSBabel package to use";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional GPS-related packages to install";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    
    # GPSBabel doesn't require special environment variables,
    # but we can add any GPS-related tools here if needed
  };
}