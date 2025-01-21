{ config, lib, pkgs, ... }:

{
  # ROG laptop specific configuration
  boot = {
    kernelModules = [ 
      "acpi_call"
      "asus-wmi"
      "asus-nb-wmi"
      "asus_wmi_ec"
      "asus-wmi-sensors"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ 
      acpi_call
      asus-wmi-sensors
    ];
    kernelParams = [
      "asus.use_lid_flip_devid=0"
      "asus-nb-wmi.use_lid_flip_devid=0"
      "intel_pstate=active"
    ];
  };

  # Enable acpilight for backlight control
  hardware.acpilight.enable = true;

  # ASUS ROG services
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd.enable = true;
    power-profiles-daemon.enable = false;
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

  # ROG-specific packages
  environment.systemPackages = with pkgs; [
    light  # Backlight control utility
    asusctl  # ROG laptop control
    supergfxctl  # Graphics switching
  ];
}
