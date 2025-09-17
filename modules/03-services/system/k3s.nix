{ config, lib, pkgs, ... }:

# This module enables and configures k3s, a lightweight Kubernetes distribution.
#
# The kubeconfig file will be created with 644 permissions (readable by all users)
# at /etc/rancher/k3s/k3s.yaml, so kubectl can be used without sudo.
#
# The KUBECONFIG environment variable is automatically set to /etc/rancher/k3s/k3s.yaml
# for all users, so kubectl commands will work without additional configuration.

with lib;

let
  cfg = config.maxos.tools.k3s;
in {
  options.maxos.tools.k3s = {
    enable = mkEnableOption "k3s lightweight Kubernetes";
    
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

  config = mkIf cfg.enable {
    # Install k3s and kubectl
    environment.systemPackages = with pkgs; [
      k3s
      kubectl
      kubernetes-helm
    ];

    # Configure and enable k3s service
    systemd.services.k3s = {
      description = "k3s: Lightweight Kubernetes";
      documentation = [ "https://k3s.io" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      
      path = [ pkgs.k3s ];
      
      serviceConfig = {
        Type = "notify";
        KillMode = "process";
        Delegate = "yes";
        LimitNOFILE = "infinity";
        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        TasksMax = "infinity";
        TimeoutStartSec = "0";
        Restart = "always";
        RestartSec = "5s";
        ExecStart = let
          args = if cfg.role == "server" then
            [ "server"
              "--write-kubeconfig-mode" "644"  # Make kubeconfig readable by all users
            ] ++ cfg.extraFlags
          else
            [ "agent"
              "--server" cfg.serverAddr
              "--token" cfg.token
            ] ++ cfg.extraFlags;
        in "${pkgs.k3s}/bin/k3s ${concatStringsSep " " args}";
      };
    };

    # Configure firewall for k3s
    networking.firewall = mkIf (cfg.role == "server") {
      allowedTCPPorts = [ 6443 ];  # Kubernetes API
    };

    # Set up KUBECONFIG environment variable for all users
    environment.variables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };
  };
}