{ config, lib, pkgs, ... }:

# MaxOS Flyctl Tool Module (Layer 4 - Applications)
#
# This module provides flyctl (Fly.io CLI) for managing Fly.io apps,
# following layered architecture conventions.

with lib;

let
  cfg = config.maxos.tools.flyctl;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.flyctl = {
    enable = mkEnableOption "Fly.io CLI (flyctl)";
    
    configDir = mkOption {
      type = types.str;
      default = "/home/${config.maxos.user.name}/.fly";
      description = "Fly.io configuration directory";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS flyctl tool requires user module to be enabled";
      }
    ];

    # Install flyctl
    environment.systemPackages = [
      pkgs.flyctl
    ];

    # Environment variables for flyctl
    environment.variables = {
      FLY_CONFIG_DIR = cfg.configDir;
    };
    
    # Create Fly.io config directory with proper permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0700 ${config.maxos.user.name} users -"
    ];
  };
}
