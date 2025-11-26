{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.appflowy;
  # In home-manager context, use home.homeDirectory
  userConfig = {
    homeDirectory = config.home.homeDirectory;
  };
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # AppFlowy has no hard dependencies
  
in {
  options.maxos.tools.appflowy = {
    enable = mkEnableOption "AppFlowy knowledge management and productivity application";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    home.packages = [ pkgs.appflowy ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "AppFlowy knowledge management application has no hard dependencies";
      }
    ];
  };
}