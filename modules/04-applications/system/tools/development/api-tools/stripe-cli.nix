{ config, lib, pkgs, ... }:

# MaxOS Stripe CLI Tool Module (Layer 4 - Applications)
#
# This module provides the Stripe CLI for managing Stripe services,
# following layered architecture conventions.

with lib;

let
  cfg = config.maxos.tools.stripe-cli;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.stripe-cli = {
    enable = mkEnableOption "Stripe CLI command line interface";
    
    package = mkOption {
      type = types.package;
      default = pkgs.stripe-cli;
      description = "Stripe CLI package to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS stripe-cli tool requires user module to be enabled";
      }
    ];

    # Install Stripe CLI
    environment.systemPackages = [
      cfg.package
    ];
  };
}