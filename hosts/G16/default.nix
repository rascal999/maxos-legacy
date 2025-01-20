{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ../../modules/security/default.nix
    ../../modules/desktop/default.nix
  ];

  # Boot loader configuration
  # Hardware scanning
  hardware.enableAllFirmware = true;

  # Networking
  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd"; # Modern WiFi backend
    };
    wireless.enable = false; # Disable wpa_supplicant in favor of NetworkManager
  };

  # Enable firmware for common WiFi chips
  hardware.enableRedistributableFirmware = true;

  # Boot configuration
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
      luks.devices = {
        cryptroot = {
          device = "/dev/disk/by-uuid/64f62ad3-8fcc-4475-afcb-a49952fe77d1";
          preLVM = true;
          allowDiscards = true;
          bypassWorkqueues = true;
        };
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
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

  # Disable system-wide Firefox
  programs.firefox.enable = false;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security.enable = true;

  # Enable X11 windowing system
  services.xserver = {
    enable = true;
    
    # Display manager configuration
    displayManager = {
      lightdm = {
        enable = true;
        background = "#000000";
        greeters.gtk = {
          enable = true;
          theme.name = "Adwaita-dark";
        };
      };
      defaultSession = "none+i3";
    };

    # Window manager configuration
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
    };
    
    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "dvorak";
      options = "terminate:ctrl_alt_bksp";
    };

    # NVIDIA configuration
    videoDrivers = [ "nvidia" ];

    # Server flags
    serverFlagsSection = ''
      Option "AllowEmptyInput" "on"
      Option "AutoAddDevices" "on"
      Option "AutoEnableDevices" "on"
    '';
  };

  # NVIDIA and graphics settings
  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;  # Disable for stability
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vaapiVdpau
        libvdpau-va-gl
      ];
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
