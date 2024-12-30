{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/default.nix
  ];

  # Server-specific configuration
  services = {
    # Disable unnecessary services for headless operation
    xserver.enable = false;
    printing.enable = false;
    pipewire.enable = false;
    
    # Common server services
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  # Minimal package set for servers
  environment.systemPackages = with pkgs; [
    # System utilities
    htop
    iotop
    iftop
    nethogs
    tcpdump
    
    # Monitoring
    prometheus-node-exporter
    
    # System maintenance
    tmux
    screen
  ];

  # Security hardening for servers
  security = {
    audit.enable = true;
    auditd.enable = true;
    
    # Stricter SSH configuration
    sshd = {
      allowTcpForwarding = false;
      extraConfig = ''
        MaxAuthTries 3
        MaxSessions 2
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
      '';
    };
  };

  # Networking
  networking = {
    firewall = {
      enable = true;
      allowPing = false;
      logRefusedConnections = true;
    };
  };

  # Disable sound
  sound.enable = false;
  hardware.pulseaudio.enable = false;

  # Disable bluetooth
  hardware.bluetooth.enable = false;

  # System optimization
  boot = {
    # Kernel hardening
    kernelParams = [
      "audit=1"
      "slab_nomerge"
      "slub_debug=FZ"
      "page_poison=1"
    ];
    
    # Clean /tmp on boot
    cleanTmpDir = true;
  };

  # Disable unnecessary hardware services
  services.udisks2.enable = false;
  services.upower.enable = false;
  services.acpid.enable = false;
  services.thermald.enable = false;
}
