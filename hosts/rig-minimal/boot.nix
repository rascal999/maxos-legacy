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
      
      # LUKS modules - disko will handle device configuration
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

  # Filesystem configuration handled by disko

  # Minimal packages for testing
  environment.systemPackages = with pkgs; [
    cryptsetup # LUKS tools
    pciutils   # lspci for hardware debugging
    usbutils   # lsusb for USB debugging
  ];
}