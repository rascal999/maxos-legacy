{ config, lib, pkgs, ... }:

{
  # Hardware scanning
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Boot configuration
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ 
      "quiet"
      "nvidia-drm.modeset=1"
    ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      luks.devices = {
        cryptroot = {
          device = "/dev/disk/by-uuid/64f62ad3-8fcc-4475-afcb-a49952fe77d1";
          preLVM = true;
          allowDiscards = true;
          bypassWorkqueues = true;
        };
      };
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

  environment.systemPackages = with pkgs; [
    os-prober  # OS detection for GRUB
  ];
}
