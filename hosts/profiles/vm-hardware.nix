{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # Basic VM hardware configuration
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Simple filesystem setup for VM
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # No swap for test VM
  swapDevices = [ ];

  # VM-specific settings
  networking.useDHCP = lib.mkDefault true;
  
  # Basic hardware settings
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
