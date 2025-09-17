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
          device = "/dev/disk/by-uuid/6f4fecf6-9f3f-4fac-9248-b216822b302f";
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
      device = "/dev/disk/by-uuid/a9db45e6-b2b4-4171-978c-73bb324781c5";
      fsType = "ext4";
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/39AD-D3AF";
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
