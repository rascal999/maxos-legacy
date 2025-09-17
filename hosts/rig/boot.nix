{ config, lib, pkgs, ... }:

{
  # Hardware scanning
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Boot configuration
  boot = {
    kernelPackages = pkgs.linuxPackages_6_12; # Use stable kernel compatible with NVIDIA
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ 
      "quiet"
      "nvidia-drm.modeset=1"
    ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      
      # LUKS support
      luks.devices = {
        cryptroot = {
          device = "/dev/disk/by-uuid/e45b126b-d2ee-448e-912f-7076380cfa26";
          preLVM = true;
          allowDiscards = true;
          bypassWorkqueues = true;
        };
      };

      # Ensure LUKS modules are included
      kernelModules = [
        "aes"
        "aesni_intel"
        "cryptd"
        "dm_crypt"
        "dm_mod"
      ];
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        enableCryptodisk = true;
        useOSProber = true;
      };
    };
  };

  # Filesystem configuration
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a6d30279-d2aa-47c0-9b8d-19adfd9c735c";
      fsType = "ext4";
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1677-DACD";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  # Add required packages for boot and OS detection
  environment.systemPackages = with pkgs; [
    os-prober  # OS detection for GRUB
    ntfs3g     # NTFS support for Windows partitions
    cryptsetup # LUKS tools
  ];
}
