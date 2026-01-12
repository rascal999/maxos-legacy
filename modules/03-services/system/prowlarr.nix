{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.services.prowlarr;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.services.prowlarr = {
    enable = mkEnableOption "Prowlarr indexer manager";
    
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open ports in the firewall for Prowlarr";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    services.prowlarr = {
      enable = true;
      openFirewall = cfg.openFirewall;
      # Force listening on localhost only via settings
      settings = {
        server = {
          bindaddress = "127.0.0.1";
        };
      };
    };

    assertions = [
      {
        assertion = dependenciesValid;
        message = "Prowlarr requires the user module to be enabled";
      }
    ];
  };
}