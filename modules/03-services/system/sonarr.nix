{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.services.sonarr;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.services.sonarr = {
    enable = mkEnableOption "Sonarr PVR for Usenet and BitTorrent users";
    
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open ports in the firewall for Sonarr";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    services.sonarr = {
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
        message = "Sonarr requires the user module to be enabled";
      }
    ];
  };
}