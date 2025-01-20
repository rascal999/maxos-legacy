{ config, lib, pkgs, ... }:

{
  # ROG laptop specific configuration
  boot = {
    kernelModules = [ "acpi_call" "asus-wmi" "asus-nb-wmi" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  # Use native ASUS backlight control
  hardware.acpilight.enable = false;

  # ASUS ROG services
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd.enable = true;
    power-profiles-daemon.enable = true;
  };

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
  ];
}
