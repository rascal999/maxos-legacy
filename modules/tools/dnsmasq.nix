{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.dnsmasq;
in {
  options.modules.tools.dnsmasq = {
    enable = mkEnableOption "Enable dnsmasq for local DNS resolution";
    
    testDomains = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to resolve *.test domains to 192.168.0.100";
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration for dnsmasq";
    };
  };

  config = mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      settings = {
        # Listen only on localhost interface
        listen-address = "127.0.0.1";
        
        # Don't use /etc/resolv.conf
        no-resolv = true;
        
        # Use Google and Cloudflare DNS for non-local domains
        server = [
          "8.8.8.8"
          "1.1.1.1"
          # Forward cluster internal DNS requests to CoreDNS (replace IP if needed)
          "/cluster.local/10.43.0.10"
        ];
      } // (optionalAttrs cfg.testDomains {
        # Resolve all .test domains to 192.168.0.100
        address = "/.test/192.168.0.100";
      }) // (if cfg.extraConfig != "" then {
        # Include any extra configuration
        conf-file = pkgs.writeText "dnsmasq-extra.conf" cfg.extraConfig;
      } else {});
    };
    
    # Configure system to use the local dnsmasq instance first
    networking.nameservers = [ "127.0.0.1" ];
    
    # Disable systemd-resolved to avoid conflicts
    services.resolved.enable = false;
    
    # Add dnsmasq to system packages for debugging
    environment.systemPackages = [ pkgs.dnsmasq ];
  };
}