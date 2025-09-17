{ config, lib, pkgs, ... }:

{
  # Hardware scanning
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Boot configuration
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; # This will use the latest kernel from unstable channel
    kernelModules = [ "kvm-intel" ]; # Enable KVM support
    kernelParams = [ 
      "acpi_osi=Linux" 
      "acpi_osi=!Windows2013" 
      "acpi_osi=!Windows2012"
      "acpi_backlight=vendor"
      "asus.use_native_led=1"
      "pcie_aspm.policy=powersave"
      "intel_pstate=powersave"
      "nvidia.NVreg_DynamicPowerManagement=0x02"
    ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ "asus-nb-wmi" ];
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
        # Reduce os-prober verbosity and device mapper warnings
        extraConfig = ''
          # Suppress os-prober warnings about device mapper devices
          GRUB_DISABLE_OS_PROBER_WARNINGS=true
        '';
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

  # Disable asusctl slash display on boot
  systemd.services.asus-slash-display = {
    description = "Disable ASUS slash display";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.asusctl}/bin/asusctl slash -d";
      RemainAfterExit = true;
    };
  };
}
