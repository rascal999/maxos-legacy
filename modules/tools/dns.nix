{ config, lib, pkgs, ... }:

# DNS configuration for resolving *.host domains to localhost
# After applying changes:
# 1. sudo nixos-rebuild switch --flake .#rig
# 2. sudo systemctl restart dnsmasq
# 3. Test with: dig @127.0.0.1 test.host

{
  # Configure DNS resolution for *.host domains
  networking = {
    # Use system DNS resolver
    networkmanager = {
      enable = true;
      dns = "none";  # Let dnsmasq handle DNS
    };

    # Point to local dnsmasq
    nameservers = [ "127.0.0.1" ];
  };

  # Configure dnsmasq service
  services.dnsmasq = {
    enable = true;
    settings = {
      # Resolve .host domains to localhost
      address = [ "/.host/127.0.0.1" ];
      
      # Use Cloudflare DNS for other domains
      server = [ "1.1.1.1" "1.0.0.1" ];
      
      # Only listen on localhost
      bind-interfaces = true;
      interface = [ "lo" ];
      listen-address = [ "127.0.0.1" ];
      
      # Enable DNS cache
      cache-size = 1000;
      
      # Log queries for debugging
      log-queries = true;
    };
  };

  # Disable systemd-resolved to avoid port conflicts
  services.resolved.enable = false;

  # Install dig for DNS testing
  environment.systemPackages = with pkgs; [
    bind  # Provides dig command
  ];
}