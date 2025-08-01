{ config, lib, ... }:

with lib;

let
  cfg = config.security;
in {
  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      # Restrict dmesg access
      "kernel.dmesg_restrict" = 1;
      # Protect against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
      # Protect against time-wait assassination
      "net.ipv4.tcp_rfc1337" = 1;
      # Protect against ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      # Protect against IP spoofing - but allow for container networking
      # Set to loose mode (2) instead of strict (1) for container compatibility
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.default.rp_filter" = 2;
      
      # Container networking requirements
      # Enable IP forwarding for container-to-container communication
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      
      # Bridge netfilter settings for Kubernetes/Docker
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.bridge.bridge-nf-call-arptables" = 1;
      
      # Increase connection tracking limits for container workloads
      "net.netfilter.nf_conntrack_max" = 1048576;
      "net.netfilter.nf_conntrack_buckets" = 262144;
      
      # Optimize for container networking
      "net.core.somaxconn" = 32768;
      "net.ipv4.tcp_max_syn_backlog" = 8096;
      "net.core.netdev_max_backlog" = 16384;
    };
    
    # Load required kernel modules for container networking
    boot.kernelModules = [
      "br_netfilter"  # Bridge netfilter support
      "overlay"       # OverlayFS for container layers
      "xt_REDIRECT"   # iptables REDIRECT target
      "xt_owner"      # iptables owner match
      "iptable_nat"   # iptables NAT table
      "iptable_filter" # iptables filter table
    ];
  };
}
