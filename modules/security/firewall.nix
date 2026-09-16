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
        80    # HTTP (host Go service)
        443   # HTTPS
        22000 # Syncthing transfer
      ];
      # Lab listeners: unprivileged host services (staging, shells), outside the
      # k3s NodePort range so kube-proxy does not intercept these SYNs.
      allowedTCPPortRanges = [
        { from = 40000; to = 40019; }
      ];
      allowedUDPPorts = [
        22000 # Syncthing transfer
        21027 # Syncthing discovery
      ];
      # Lab (HTB VPN): stateful UDP replies arrive from new ephemeral source
      # ports (tftpd transfer sockets) and are not conntrack ESTABLISHED.
      # Covers all client-side ephemeral dports. 2026-09-09, Expressway session.
      allowedUDPPortRanges = [
        { from = 1024; to = 65535; }
      ];
      # Allow traffic on Docker and Kubernetes bridge interfaces
      trustedInterfaces = [
        "lo"          # Loopback interface (localhost/127.0.0.1)
        "docker0"     # Default Docker bridge
        "br-+"        # Docker custom bridges (pattern match)
        "cni+"        # CNI interfaces (pattern match)
        "flannel+"    # Flannel interfaces (pattern match)
        "weave"       # Weave Net interface
        "kube-bridge" # Kubernetes bridge
      ];
      allowPing = false;
      # Change from rejectPackets to false to avoid interfering with container networking
      rejectPackets = false;
      logReversePathDrops = true;
      # Allow forwarding for container networking
      checkReversePath = false;
    };
  };
}
