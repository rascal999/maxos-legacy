{ config, pkgs, lib, ... }:

{
  networking = {
    # Enable NetworkManager for network configuration
    networkmanager = {
      enable = true;
      wifi.backend = "iwd"; # Use iwd for better WiFi performance
      
      # DNS settings
      dns = "systemd-resolved";
      
      # Connection sharing
      connectionSharing = true;
      
      # WiFi powersave
      wifi.powersave = true;
    };

    # Enable systemd-resolved for DNS resolution
    nameservers = [ "1.1.1.1" "1.0.0.1" ]; # Cloudflare DNS
    
    # Firewall configuration
    firewall = {
      enable = true;
      allowPing = false;
      
      # Default allowed ports
      allowedTCPPorts = [
        22    # SSH
        80    # HTTP
        443   # HTTPS
        3000  # Common development port
        5900  # VNC
        8080  # Alternative HTTP
      ];
      
      allowedUDPPorts = [
        51820  # WireGuard
      ];
      
      # Extra rules using nftables syntax
      extraCommands = ''
        # Allow established and related connections
        nft add rule inet filter input ct state established,related accept
        
        # Rate limit incoming connections
        nft add rule inet filter input tcp dport 22 limit rate 10/minute accept
        
        # Drop invalid packets
        nft add rule inet filter input ct state invalid drop
        
        # Log and drop everything else
        nft add rule inet filter input counter log prefix "DROP: " drop
      '';
    };

    # WireGuard VPN configuration
    wg-quick.interfaces = {
      # Example WireGuard interface - customize as needed
      wg0 = {
        autostart = false;
        privateKeyFile = config.age.secrets.wireguard-private-key.path;
        peers = [
          {
            # Example peer configuration
            publicKey = "peer_public_key";
            allowedIPs = [ "10.0.0.0/24" ];
            endpoint = "vpn.example.com:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  # Enable systemd-resolved
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "9.9.9.9" "149.112.112.112" ]; # Quad9 DNS
    extraConfig = ''
      DNSOverTLS=yes
      Cache=yes
      DNSStubListener=yes
    '';
  };

  # Network optimization
  boot.kernel.sysctl = {
    # Increase network performance
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    
    # Enable BBR congestion control
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    
    # Security settings
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.tcp_syncookies" = 1;
  };

  # User-specific network configuration
  home-manager.users.user = { pkgs, ... }: {
    # Network tools
    home.packages = with pkgs; [
      # Network utilities
      iperf3
      mtr
      nmap
      wireshark
      tcpdump
      
      # VPN clients
      wireguard-tools
      openvpn
      
      # Remote access
      remmina
      freerdp
      
      # Network monitoring
      nethogs
      iftop
      bandwhich
    ];

    # Network manager applet
    services.network-manager-applet.enable = true;

    # SSH configuration
    programs.ssh = {
      enable = true;
      
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/github";
        };
        
        "gitlab.com" = {
          hostname = "gitlab.com";
          user = "git";
          identityFile = "~/.ssh/gitlab";
        };
      };
      
      extraConfig = ''
        AddKeysToAgent yes
        ServerAliveInterval 60
        
        Host *
          UseKeychain yes
          AddKeysToAgent yes
          IdentitiesOnly yes
          HashKnownHosts yes
          VisualHostKey yes
          ControlMaster auto
          ControlPath ~/.ssh/control-%C
          ControlPersist 10m
      '';
    };
  };

  # Age secrets for network-related credentials
  age.secrets = {
    wireguard-private-key = {
      file = ../../secrets/wireguard-private-key.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
