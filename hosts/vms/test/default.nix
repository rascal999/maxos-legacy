{ config, pkgs, lib, ... }:

{
  imports = [
    # Import desktop configuration as base
    ../../desktop
  ];

  # VM-specific settings
  virtualisation = {
    # QEMU settings
    qemu = {
      guestAgent.enable = true;
      options = [
        # Hardware acceleration
        "-cpu host"
        "-machine type=q35,accel=kvm"
        # Memory balloon device for dynamic memory allocation
        "-device virtio-balloon"
        # Enable clipboard sharing
        "-device qemu-xhci"
        "-device usb-tablet"
        "-device virtio-keyboard"
      ];
    };
    
    # Shared folders configuration
    sharedDirectories = {
      shared = {
        source = "/home/user/shared";
        target = "/mnt/shared";
      };
    };
  };

  # Override some desktop settings for VM environment
  services.xserver = {
    # Use more modest resolution
    resolutions = [
      { x = 1920; y = 1080; }
      { x = 1600; y = 900; }
      { x = 1366; y = 768; }
    ];
    
    # Disable power management in VM
    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };

  # Disable power management
  powerManagement.enable = false;
  services.tlp.enable = false;

  # Network configuration specific to VM
  networking = {
    hostName = "vm-test";
    useDHCP = true;
    
    # Simplified firewall rules for testing
    firewall = {
      allowedTCPPorts = [ 22 80 443 3000 8080 ];
      allowPing = true;
    };
  };

  # Disable some services that aren't needed in VM
  services = {
    printing.enable = false;
    bluetooth.enable = false;
  };

  # VM-specific user configuration
  home-manager.users.user = { pkgs, ... }: {
    # Disable some desktop applications in VM
    home.packages = with pkgs; [
      # Only essential development tools
      vscode
      git
      curl
      wget
    ];

    # Simplified Sway configuration for VM
    wayland.windowManager.sway = {
      config = {
        # Simpler window management
        workspaceLayout = "tabbed";
        
        # Disable idle configuration
        idle = null;
        
        # Simplified key bindings
        keybindings = let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${modifier}+q" = "kill";
          "${modifier}+d" = "exec ${pkgs.wofi}/bin/wofi --show drun";
        };
      };
    };
  };

  # Testing tools
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    iotop
    
    # Network testing
    iperf3
    curl
    wget
    
    # Development
    git
    vim
    
    # Testing utilities
    python3
    jq
  ];

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Automatic cleanup
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Development environment
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    enableTCPIP = true;
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
    '';
  };

  # Container support
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # System state version
  system.stateVersion = "23.11";
}
