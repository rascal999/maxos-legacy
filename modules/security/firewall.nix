{ config, lib, ... }:

with lib;

let
  cfg = config.security;
in {
  config = mkIf (cfg.enable && cfg.firewallEnable) {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH
        22000 # Syncthing Transfer Protocol
        11434 # Ollama
        3000  # Open WebUI
      ];
      allowedUDPPorts = [
        22000 # Syncthing Transfer Protocol
        21027 # Syncthing Discovery Protocol
      ];
      allowPing = false;
      rejectPackets = true;
      logReversePathDrops = true;
    };
  };
}
