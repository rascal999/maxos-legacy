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

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Enable TLP for advanced power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 60;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      
      # Disable wireless power management
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";
      WOL_DISABLE = "Y";
    };
  };

  # CPU frequency scaling
  services.thermald.enable = true;

  # Powertop auto-tune service
  systemd.services.powertop-auto-tune = {
    description = "Powertop auto-tune";
    wantedBy = [ "multi-user.target" ];
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
    };
  };

  # Set CPU governor and disable turbo boost on battery
  systemd.services.power-management = {
    description = "Power management settings";
    after = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.linuxPackages.cpupower ];
    script = ''
      # Set CPU governor
      cpupower frequency-set -g powersave
      
      # Disable turbo boost on battery
      echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # ROG-specific packages
  environment.systemPackages = with pkgs; [
    light  # Backlight control utility
    asusctl  # ROG laptop control
    supergfxctl  # Graphics switching
    powertop  # Power management
    linuxPackages.cpupower  # CPU frequency control
    tlp  # Advanced power management
  ];
}
