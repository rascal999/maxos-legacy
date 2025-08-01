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
        # Kubernetes/Kind ports
        6443  # Kubernetes API server
        2379  # etcd client requests
        2380  # etcd peer communication
        10250 # kubelet API
        10251 # kube-scheduler
        10252 # kube-controller-manager
        10256 # kube-proxy health check
        # NodePort range (commonly used by services)
        30000 # Start of NodePort range
        32767 # End of NodePort range
      ];
      allowedUDPPorts = [
        22000 # Syncthing Transfer Protocol
        21027 # Syncthing Discovery Protocol
        # Kubernetes/Kind UDP ports
        8472  # Flannel VXLAN (if using Flannel CNI)
      ];
      # Allow traffic on Docker and Kubernetes bridge interfaces
      trustedInterfaces = [
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
