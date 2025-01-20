{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ../../modules/security/default.nix
  ];

  # Boot loader configuration
  boot.loader = {
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

  # File systems configuration
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/64f62ad3-8fcc-4475-afcb-a49952fe77d1"; # Replace with actual UUID
      preLVM = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1677-DACD"; # Replace with actual UUID
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
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "terminate:ctrl_alt_bksp";
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
