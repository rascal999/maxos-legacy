{ config, lib, pkgs, ... }:

# This module enables and configures kind (Kubernetes in Docker).
# Kind is a tool for running local Kubernetes clusters using Docker container "nodes".

with lib;

let
  cfg = config.modules.tools.kind;
in {
  options.modules.tools.kind = {
    enable = mkEnableOption "kind (Kubernetes in Docker)";
    
    clusters = mkOption {
      type = types.listOf types.str;
      default = [ "kind" ];
      description = "List of kind cluster names to create";
    };
    
    nodeImage = mkOption {
      type = types.str;
      default = "kindest/node:v1.29.0";
      description = "Docker image to use for kind nodes";
    };
    
    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "Extra configuration for kind clusters (YAML format)";
    };
  };

  config = mkIf cfg.enable {
    # Install kind and kubectl
    environment.systemPackages = with pkgs; [
      kind
      kubectl
      kubernetes-helm
      # Additional networking tools for debugging
      dig
      nmap
      netcat-gnu
      tcpdump
      iptables
    ];

    # Ensure Docker is enabled (kind requires Docker)
    virtualisation.docker.enable = true;
    
    # Add user to docker group for kind access
    users.users.user.extraGroups = [ "docker" ];
    
    # Configure systemd-resolved for better DNS in containers
    services.resolved = {
      enable = true;
      dnssec = "false"; # Disable DNSSEC for compatibility
      domains = [ "~." ]; # Accept DNS for all domains
      fallbackDns = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
      extraConfig = ''
        DNS=8.8.8.8 8.8.4.4 1.1.1.1
        FallbackDNS=8.8.8.8 8.8.4.4
        Domains=~.
        DNSSEC=false
        DNSOverTLS=false
        MulticastDNS=false
        LLMNR=false
        Cache=true
        DNSStubListener=true
        ReadEtcHosts=true
      '';
    };
    
    # Ensure proper DNS resolution for containers
    environment.etc."docker/daemon.json".text = builtins.toJSON {
      dns = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
      dns-opts = [ "ndots:2" "timeout:3" "attempts:2" ];
      dns-search = [ "default.svc.cluster.local" "svc.cluster.local" "cluster.local" ];
    };
    
    # Create a systemd service to ensure Kind networking is properly configured
    systemd.services.kind-network-setup = {
      description = "Setup networking for Kind clusters";
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "kind-network-setup" ''
          # Ensure bridge netfilter module is loaded
          ${pkgs.kmod}/bin/modprobe br_netfilter || true
          
          # Set up sysctl parameters if not already set
          echo 1 > /proc/sys/net/ipv4/ip_forward || true
          echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables || true
          echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables || true
          
          # Create kind network if it doesn't exist
          ${pkgs.docker}/bin/docker network create kind --driver=bridge --subnet=172.18.0.0/16 || true
        '';
      };
    };
  };
}