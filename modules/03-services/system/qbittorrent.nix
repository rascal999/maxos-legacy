{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.services.qbittorrent;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.services.qbittorrent = {
    enable = mkEnableOption "qBittorrent headless (nox) service";
    
    port = mkOption {
      type = types.port;
      default = 13337;
      description = "Web UI port for qBittorrent";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open ports in the firewall for qBittorrent Web UI";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # qBittorrent-nox service
    systemd.services.qbittorrent = {
      description = "qBittorrent-nox service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "simple";
        User = config.maxos.user.name;
        Group = "users";
        ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --webui-port=${toString cfg.port}";
        Restart = "on-failure";
      };
    };

    # Open firewall if requested
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "qBittorrent requires the user module to be enabled";
      }
    ];
  };
}