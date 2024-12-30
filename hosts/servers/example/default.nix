{ config, pkgs, lib, ... }:

{
  imports = [
    ../../profiles/server.nix        # Common server configuration
    ./hardware-configuration.nix      # Machine-specific hardware config
  ];

  # Machine-specific configuration
  networking = {
    hostName = "server-example";
    
    # Server-specific networking
    interfaces = {
      ens3 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.1.100";
          prefixLength = 24;
        }];
      };
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    
    # Additional firewall rules
    firewall = {
      allowedTCPPorts = [ 80 443 ];  # Web server ports
    };
  };

  # Server-specific services
  services = {
    # Example: Web server
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
    
    # Example: Database
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      enableTCPIP = false;  # Local connections only
    };
  };

  # Additional packages specific to this server
  environment.systemPackages = with pkgs; [
    # Monitoring tools
    netdata
    grafana
    prometheus
    
    # Backup tools
    restic
    rclone
  ];

  # System state version
  system.stateVersion = "23.11";
}
