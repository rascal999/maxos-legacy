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
    kernelModules = [ "kvm-intel" "acpi_call" "asus-wmi" "asus-nb-wmi" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
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

    # Server flags
    serverFlagsSection = ''
      Option "AllowEmptyInput" "on"
      Option "AutoAddDevices" "on"
      Option "AutoEnableDevices" "on"
    '';
  };

  # ROG G16 specific configuration
  hardware.graphics.enable = true;

  # Enable ACPI backlight control
  hardware.acpilight.enable = true;

  # Map F7/F8 to brightness controls
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xmodmap}/bin/xmodmap -e "keycode 73 = XF86MonBrightnessDown"  # F7
    ${pkgs.xorg.xmodmap}/bin/xmodmap -e "keycode 74 = XF86MonBrightnessUp"    # F8
  '';

  # Enable backlight control
  programs.light.enable = true;

  # Enable backlight control
  services.udev.extraRules = ''
    # Keyboard backlight control
    ACTION=="add", SUBSYSTEM=="leds", KERNEL=="asus::kbd_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
    ACTION=="add", SUBSYSTEM=="leds", KERNEL=="asus::kbd_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
    
    # Screen backlight control
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="*", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="*", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';

  # Add user to video group for backlight control
  users.users.user.extraGroups = [ "video" ];

  # ASUS ROG services
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd.enable = true;
    power-profiles-daemon.enable = true;
    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
  };

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # ROG-specific packages
  environment.systemPackages = with pkgs; [
    light  # Backlight control utility
    asusctl  # ROG laptop control
    supergfxctl  # Graphics switching
    powertop  # Power management
    redshift  # Color temperature adjustment
    os-prober  # OS detection for GRUB
  ];

  # Configure redshift for blue light filtering
  services.redshift = {
    enable = true;
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  # Enable location services for redshift
  location.provider = "geoclue2";
  services.geoclue2.enable = true;

  # Configure home-manager
  home-manager = {
    backupFileExtension = "backup";
    users.user = { pkgs, ... }: {
      imports = [
        ./home.nix
        ../../modules/tools/i3/desktop.nix
        ../../modules/tools/alacritty.nix
        ../../modules/tools/zsh.nix
      ];
    };
  };

  # Set system state version
  system.stateVersion = "24.11";
}
