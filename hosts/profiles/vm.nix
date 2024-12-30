{ config, pkgs, lib, ... }:

{
  imports = [ ];

  # VM-specific configuration
  virtualisation = {
    # Optimize for running as a VM guest
    vmware.guest.enable = lib.mkDefault false;
    virtualbox.guest.enable = lib.mkDefault false;
    qemu.guestAgent.enable = lib.mkDefault true;
  };

  # Basic display configuration for VMs
  services.xserver = {
    enable = lib.mkForce true;
    
    # Use a lightweight desktop environment
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    
    displayManager.lightdm.enable = true;
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

  # Set default desktop session
  services.displayManager.defaultSession = "xfce";

  # VM-specific services
  services = {
    # Enable SPICE agent for better integration
    spice-vdagentd.enable = true;
    
    # Enable clipboard sharing
    spice-webdavd.enable = true;
    
    # Minimal printing support
    printing.enable = lib.mkDefault false;
    
    # Disable power management
    acpid.enable = false;
    thermald.enable = false;
  };

  # Hardware configuration
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
    tmp.cleanOnBoot = true;
  };

  # Basic filesystem setup for VM
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # No swap for test VM
  swapDevices = [ ];

  # VM-specific settings
  networking.useDHCP = lib.mkDefault true;

  # Audio configuration
  hardware.pulseaudio.enable = false;  # Using pipewire instead
  services.pipewire = {
    enable = lib.mkForce true;
    alsa.enable = lib.mkForce true;
    pulse.enable = lib.mkForce true;
  };

  # Basic hardware settings
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
