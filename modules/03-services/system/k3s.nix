{ config, lib, pkgs, ... }:

# MaxOS K3s Service Wrapper (Layer 3 - Services)
#
# This module wraps the standard NixOS k3s service with MaxOS-specific
# configuration and stability improvements, following layered architecture.

with lib;

let
  cfg = config.maxos.tools.k3s;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.k3s = {
    enable = mkEnableOption "k3s lightweight Kubernetes via MaxOS wrapper";
    
    role = mkOption {
      type = types.enum [ "server" "agent" ];
      default = "server";
      description = "Whether this node acts as a server (control plane) or agent (worker)";
    };
    
    serverAddr = mkOption {
      type = types.str;
      default = "";
      description = "The k3s server address that agents will connect to (only needed for agent role)";
    };
    
    token = mkOption {
      type = types.str;
      default = "";
      description = "The token that agents will use to register with the server (only needed for agent role)";
    };
    
    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra flags to pass to k3s";
    };
    
    traefik = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable k3s built-in traefik";
      };
      
      hostPort = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to configure traefik with hostPort for direct host network binding";
      };
      
      staticIP = mkOption {
        type = types.str;
        default = "";
        description = "Static IP for traefik LoadBalancer service (e.g., '127.0.0.2')";
      };
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS k3s wrapper requires user module to be enabled";
      }
    ];

    # Use standard NixOS k3s service with MaxOS enhancements
    services.k3s = {
      enable = true;
      role = cfg.role;
      serverAddr = mkIf (cfg.role == "agent") cfg.serverAddr;
      token = mkIf (cfg.role == "agent") cfg.token;
      # Use clusterInit for fresh installations (cluster data was cleaned)
      clusterInit = mkIf (cfg.role == "server") true;  # Required for first node
      extraFlags = (if cfg.role == "server" then [
        # IPv4 binding fixes to prevent IPv6 localhost issues
        "--bind-address=0.0.0.0"
        # Let K3S auto-detect the advertise address (don't use loopback)
        "--kube-apiserver-arg=bind-address=0.0.0.0"
        "--write-kubeconfig-mode=644"  # Make kubeconfig readable by all users
      ] else []) ++ (if cfg.traefik.enable == false then [
        "--disable=traefik"  # Disable built-in traefik when explicitly disabled
      ] else []) ++ (if cfg.traefik.staticIP != "" then [
        "--disable=servicelb"  # Disable built-in ServiceLB when using static IP
      ] else []) ++ cfg.extraFlags;
    };
    
    # Set up secondary loopback IP when staticIP is configured
    systemd.services.k3s-traefik-staticip = mkIf (cfg.role == "server" && cfg.traefik.enable && cfg.traefik.staticIP != "") {
      description = "Set up static IP for traefik";
      before = [ "k3s.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip addr add ${cfg.traefik.staticIP}/8 dev lo";
        ExecStop = "${pkgs.iproute2}/bin/ip addr del ${cfg.traefik.staticIP}/8 dev lo";
      };
    };
    
    # Create proxy services to forward from static IP to traefik ClusterIP
    systemd.services.k3s-traefik-proxy-http = mkIf (cfg.role == "server" && cfg.traefik.enable && cfg.traefik.staticIP != "") {
      description = "Proxy HTTP traffic from static IP to traefik";
      after = [ "k3s.service" "k3s-traefik-staticip.service" ];
      wants = [ "k3s.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:80,bind=${cfg.traefik.staticIP},reuseaddr,fork TCP:10.43.78.186:80";
      };
    };
    
    systemd.services.k3s-traefik-proxy-https = mkIf (cfg.role == "server" && cfg.traefik.enable && cfg.traefik.staticIP != "") {
      description = "Proxy HTTPS traffic from static IP to traefik";
      after = [ "k3s.service" "k3s-traefik-staticip.service" ];
      wants = [ "k3s.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:443,bind=${cfg.traefik.staticIP},reuseaddr,fork TCP:10.43.78.186:443";
      };
    };
    
    # Configure traefik manifests
    environment.etc = mkMerge [
      # Configure traefik with hostPort when enabled
      (mkIf (cfg.role == "server" && cfg.traefik.enable && cfg.traefik.hostPort) {
        "rancher/k3s/server/manifests/traefik-config.yaml".text = ''
          apiVersion: helm.cattle.io/v1
          kind: HelmChartConfig
          metadata:
            name: traefik
            namespace: kube-system
          spec:
            valuesContent: |-
              ports:
                web:
                  port: 8000
                  hostPort: 80
                  hostIP: "0.0.0.0"
                  protocol: TCP
                websecure:
                  port: 8443
                  hostPort: 443
                  hostIP: "0.0.0.0"
                  protocol: TCP
                  tls:
                    enabled: true
              securityContext:
                capabilities:
                  add:
                    - NET_BIND_SERVICE
              service:
                type: ClusterIP
              hostNetwork: false
              dnsPolicy: ClusterFirst
        '';
      })
      
      # Configure traefik with static IP using ClusterIP when enabled
      (mkIf (cfg.role == "server" && cfg.traefik.enable && cfg.traefik.staticIP != "") {
        "rancher/k3s/server/manifests/traefik-staticip-config.yaml".text = ''
          apiVersion: helm.cattle.io/v1
          kind: HelmChartConfig
          metadata:
            name: traefik
            namespace: kube-system
          spec:
            valuesContent: |-
              ports:
                web:
                  port: 8000
                  protocol: TCP
                websecure:
                  port: 8443
                  protocol: TCP
                  tls:
                    enabled: true
              service:
                type: ClusterIP
              hostNetwork: false
              dnsPolicy: ClusterFirst
        '';
      })
    ];
    
    # MaxOS-specific enhancements
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
    ] ++ (if cfg.traefik.staticIP != "" then [ socat ] else []);

    # Configure firewall for k3s (only for servers)
    networking.firewall = mkIf (cfg.role == "server") {
      allowedTCPPorts = [ 6443 ] # k3s API server
        ++ (if cfg.traefik.enable && cfg.traefik.hostPort then [ 80 443 ] else []);
    };

    # Set up KUBECONFIG environment variable for all users
    environment.variables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };
  };
}