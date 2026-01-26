{ config, lib, pkgs, ... }:

# MaxOS Google Cloud SDK Tool Module (Layer 4 - Applications)
#
# This module provides the Google Cloud SDK for managing Google Cloud services,
# following layered architecture conventions.

with lib;

let
  cfg = config.maxos.tools.google-cloud-sdk;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.google-cloud-sdk = {
    enable = mkEnableOption "Google Cloud SDK command line interface";
    
    package = mkOption {
      type = types.package;
      default = pkgs.google-cloud-sdk;
      description = "Google Cloud SDK package to install";
    };

    extraComponents = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra components to install with Google Cloud SDK";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS google-cloud-sdk tool requires user module to be enabled";
      }
    ];

    # Install Google Cloud SDK
    environment.systemPackages = [
      (if cfg.extraComponents == [] then cfg.package else cfg.package.withExtraComponents cfg.extraComponents)
    ];
  };
}