# Home Server Configuration Example
# 
# This example shows a headless server configuration with common services
# Copy to hosts/your-hostname/default.nix and customize as needed

{ config, pkgs, ... }:
{
  imports = [
    # Include your hardware configuration
    ./hardware-configuration.nix
  ];

  # Configure the primary user
  maxos.user = {
    name = "server";
    homeDirectory = "/home/server";
    gitDirectory = "/srv/git";
    monorepoDirectory = "/srv/git/maxos";
    secretsDirectory = "/srv/secrets";
  };

  # Enable secrets management
  maxos.secrets.enable = true;

  # Enable server tool bundle
  modules.toolBundles.server = {
    enable = true;
    kubernetes = true;
    networking = true;
    databases = true;
    monitoring = true;
    vcs = true;
    backup = true;
  };

  # Enable security tools for server hardening
  modules.toolBundles.security = {
    enable = true;
    scanners = true;
    crypto = true;
    monitoring = true;
  };

  # Enable development tools for maintenance
  modules.toolBundles.development = {
    enable = true;
    git = true;
    containerization = true;
  };

  # Configure specific services
  modules.tools = {
    # Container orchestration
    k3s = {
      enable = true;
      # Additional k3s configuration would go here
    };
    
    # Reverse proxy
    traefik = {
      enable = true;
      # Configure traefik for your services
    };
    
    # DNS and ad blocking
    blocky = {
      enable = true;
      # Configure DNS filtering
    };
    
    # Version control server
    forgejo = {
      enable = true;
      # Configure forgejo git server
    };
    
    # Backup system
    restic = {
      enable = true;
      useSopsSecrets = true;
      schedule = "*-*-* 01:00:00";  # Daily backup at 1 AM
      paths = [
        "/srv"
        "/etc"
        "/var/lib"
      ];
      excludes = [
        "*/cache"
        "*/tmp"
        "*/.cache"
        "*/node_modules"
        "*/target"
      ];
    };
    
    # Monitoring
    grafana = {
      enable = true;
      # Configure monitoring dashboards
    };
    
    # Database
    mongodb = {
      enable = true;
      # Configure database
    };
  };

  # Basic system configuration
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";  # Adjust for your system
    };
  };

  networking = {
    hostName = "homeserver";
    networkmanager.enable = true;
    
    # Open required ports
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 6443 ]; # SSH, HTTP, HTTPS, k3s
    };
  };

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Automatic updates
  system.autoUpgrade = {
    enable = true;
    flake = "/srv/git/maxos";
    dates = "04:00";
    randomizedDelaySec = "45min";
  };

  # Locale and time
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Headless system - no GUI
  services.xserver.enable = false;

  # System state version
  system.stateVersion = "25.05";
}