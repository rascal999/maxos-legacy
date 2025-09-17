{ config, lib, pkgs, ... }:

{
  # Hardware scanning
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Boot configuration - minimal setup for testing
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel for testing
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "quiet" ];
    
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
    
    # Use systemd-boot for minimal setup
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # Keep fewer generations for testing
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
      device = "/dev/disk/by-uuid/6F2D-6ACC";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  # Minimal packages for testing
  environment.systemPackages = with pkgs; [
    cryptsetup # LUKS tools
    pciutils   # lspci for hardware debugging
    usbutils   # lsusb for USB debugging
  ];
}