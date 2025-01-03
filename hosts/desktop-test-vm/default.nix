{ config, pkgs, lib, ... }:

{
  imports = [
    ../desktop
  ];

  # Configure networking and SSH for VM
  networking = {
    useDHCP = true;
    firewall.enable = lib.mkForce false;
  };

  # Enable SSH with password auth
  services.openssh = {
    enable = true;
    startWhenNeeded = false;  # Start SSH immediately, don't wait for connection
    settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = lib.mkForce true;
      ListenAddress = "0.0.0.0";  # Listen on all interfaces
    };
  };

  # Ensure SSH starts on boot
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  # Configure X server
  services.xserver = {
    enable = true;
    
    # Use LightDM with autologin
    displayManager = {
      lightdm.enable = true;
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "user";
      };
    };

    # Only enable i3 window manager
    desktopManager.xfce.enable = lib.mkForce false;
    desktopManager.gnome.enable = lib.mkForce false;
    desktopManager.plasma5.enable = lib.mkForce false;
    windowManager.i3.enable = true;
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192; # MB
      cores = 2;
      graphics = true;
      qemu.networkingOptions = [
        "-device virtio-net-pci,netdev=net0"
        "-netdev user,id=net0,hostfwd=tcp::2222-:22,net=192.168.76.0/24,dhcpstart=192.168.76.9"
      ];
    };
  };
}
