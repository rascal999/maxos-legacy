{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/default.nix
  ];

  # VM-specific configuration
  virtualisation = {
    # Optimize for running as a VM guest
    vmware.guest.enable = lib.mkDefault false;
    virtualbox.guest.enable = lib.mkDefault false;
    qemu.guest.enable = lib.mkDefault true;
  };

  # Basic display configuration for VMs
  services.xserver = {
    enable = true;
    
    # Use a lightweight desktop environment
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    
    displayManager = {
      lightdm.enable = true;
      defaultSession = "xfce";
    };
  };

  # VM-optimized packages
  environment.systemPackages = with pkgs; [
    # Basic system utilities
    htop
    wget
    curl
    
    # VM integration tools
    spice-vdagent
    
    # Basic desktop utilities
    xfce.thunar
    xfce.xfce4-terminal
    firefox
  ];

  # VM-specific services
  services = {
    # Enable SPICE agent for better integration
    spice-vdagentd.enable = true;
    
    # Enable clipboard sharing
    spice-webdavd.enable = true;
    
    # Minimal printing support
    printing.enable = false;
    
    # Disable power management
    acpid.enable = false;
    thermald.enable = false;
  };

  # Networking optimizations for VMs
  networking = {
    firewall = {
      enable = true;
      # Allow SPICE ports if needed
      allowedTCPPorts = [ 5900 ];
    };
    
    # Use simpler networking for VMs
    useDHCP = true;
    useNetworkd = false;
  };

  # Hardware configuration
  hardware = {
    # Disable unnecessary hardware support
    bluetooth.enable = false;
    pulseaudio.enable = false;
    
    # Enable basic audio
    sound.enable = true;
  };

  # Boot configuration
  boot = {
    # VM-specific kernel parameters
    kernelParams = [
      "console=tty0"
      "console=ttyS0,115200"
      "panic=30"
      "boot.panic_on_fail"
    ];
    
    # Use minimal initrd
    initrd = {
      includeDefaultModules = false;
      kernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net" ];
    };
    
    # Clean /tmp on boot
    cleanTmpDir = true;
  };

  # System optimization
  nix = {
    # Reduce system closure size
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Reduce swapping
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };
}
