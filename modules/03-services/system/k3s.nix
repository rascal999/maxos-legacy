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
      ] else []) ++ cfg.extraFlags;
    };
    
    # MaxOS-specific enhancements
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
    ];

    # Configure firewall for k3s (only for servers)
    networking.firewall = mkIf (cfg.role == "server") {
      allowedTCPPorts = [ 6443 ]; # k3s API server
    };

    # Set up KUBECONFIG environment variable for all users
    environment.variables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };
  };
}