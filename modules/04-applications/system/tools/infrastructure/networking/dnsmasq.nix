{ config, lib, pkgs, ... }:

# dnsmasq DNS resolver for wildcard DNS (*.int.alm.gg → localhost)
# Used to route k3s ingress traffic to Traefik on the local host.

with lib;

let
  cfg = config.maxos.tools.dnsmasq;
in {
  options.maxos.tools.dnsmasq = {
    enable = mkEnableOption "dnsmasq DNS resolver with wildcard support";

    wildcardZone = mkOption {
      type = types.str;
      default = "int.alm.gg";
      description = "Wildcard DNS zone to resolve to localhost (e.g., 'int.alm.gg' → *.int.alm.gg → 127.0.0.1)";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address dnsmasq listens on";
    };

    upstreamDNS = mkOption {
      type = types.listOf types.str;
      default = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
      description = "Upstream DNS servers for non-wildcard queries";
    };
  };

  config = mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      settings = {
        # Listen on localhost only
        listen-address = cfg.listenAddress;
        bind-interfaces = true;

        # Wildcard: *.int.alm.gg → 127.0.0.1
        address = "/${cfg.wildcardZone}/127.0.0.1";

        # Upstream DNS servers
        server = cfg.upstreamDNS;

        # Don't read /etc/resolv.conf (we manage it)
        no-resolv = true;

        # Cache upstream DNS queries
        cache-size = 1000;

        # Log queries for debugging (optional)
        # log-queries = true;
        # log-facility = "/var/log/dnsmasq.log";
      };
    };

    # Point system DNS to local dnsmasq
    networking.nameservers = mkForce [ cfg.listenAddress ];

    # Ensure dnsmasq starts after network
    systemd.services.dnsmasq = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
