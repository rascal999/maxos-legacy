# Safe Module Template for MaxOS
# This template follows recursion prevention guidelines
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.MODULENAME;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true &&
    config.maxos.secrets.enable or true;
    
in {
  options.maxos.MODULENAME = {
    enable = mkEnableOption "MODULENAME";
    
    # Define ALL options you plan to use here
    # Example options:
    # package = mkOption {
    #   type = types.package;
    #   default = pkgs.PACKAGENAME;
    #   description = "Package to use for MODULENAME";
    # };
    
    # configFile = mkOption {
    #   type = types.path;
    #   default = ./config/MODULENAME.conf;
    #   description = "Configuration file for MODULENAME";
    # };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # Only set options that are:
    # 1. Defined in this module's options
    # 2. Standard NixOS options
    # 3. Lower-layer maxos options
    
    # Example system configuration:
    # environment.systemPackages = [ cfg.package ];
    # systemd.services.MODULENAME = { ... };
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MODULENAME requires user and secrets modules to be enabled";
      }
      # Add more specific assertions as needed
    ];
    
    # Add warnings for common issues
    warnings = [
      # Example warning:
      # (optionalString (cfg.enable && !config.services.someService.enable)
      #   "MODULENAME works better with someService enabled")
    ];
  };
}