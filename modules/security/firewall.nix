{ config, lib, ... }:

with lib;

let
  cfg = config.security;
in {
  config = mkIf (cfg.enable && cfg.firewallEnable) {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # SSH only by default
      allowPing = false;
      rejectPackets = true;
      logReversePathDrops = true;
    };
  };
}
