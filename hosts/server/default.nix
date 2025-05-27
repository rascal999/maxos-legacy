{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ../../modules/security/default.nix
  ];

  # Enable security module with default settings
  security.enable = true;

  # Configure networking and SSH for server
  networking = {
    useDHCP = true;
    wireless.enable = false;
    networkmanager.enable = false;
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    startWhenNeeded = false;
    settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = lib.mkForce false;
      ListenAddress = "0.0.0.0";
    };
  };

  # Ensure SSH starts on boot
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  # Add required packages
  environment.systemPackages = with pkgs; [
    # System administration
    htop
    btop
    iotop
    iftop
    nethogs
    nmap
    tcpdump
    mtr
    
    # Terminal utilities
    neovim
    ripgrep
    fd
    jq
    tree
    wget
    curl
    unzip
    tmux
    
    # Monitoring and logging
    prometheus
    grafana
    lnav
    
    # Development tools
    git
    gh
    
    # Security tools
    fail2ban
    ufw
    
    # System tools
    smartmontools
    lm_sensors
    ethtool
    pciutils
    usbutils
    
    # Backup tools
    restic
    rclone
    goose-cli # Database migration tool
  ];

  # Set system state version
  system.stateVersion = "25.05";
}