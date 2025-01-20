{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ../../modules/security/default.nix
  ];

  # Boot loader configuration
  # Hardware scanning
  hardware.enableAllFirmware = true;

  # Boot configuration
  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" "dm-crypt" "dm-mod" "cbc" "sha256" "sha512" "aes" ];
      luks.devices = {
        cryptroot = {
          device = "/dev/nvme1n1p2";
          preLVM = true;
          allowDiscards = true;
          bypassWorkqueues = true;
        };
      };
    };
    kernelModules = [ "kvm-intel" ];
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
      };
    };
  };


  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
      options = [ "defaults" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/07F8-7AAD";
      fsType = "vfat";
    };
  };

  # Disable system-wide Firefox
  programs.firefox.enable = false;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security.enable = true;

  # Enable X11 windowing system
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
    
    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "dvorak";
      options = "terminate:ctrl_alt_bksp";
    };
  };

  # Configure home-manager
  home-manager.users.user = { pkgs, ... }: {
    imports = [
      ./home.nix
      ../../modules/tools/i3/desktop.nix
      ../../modules/tools/alacritty.nix
      ../../modules/tools/zsh.nix
    ];
  };

  # Set system state version
  system.stateVersion = "24.11";
}
