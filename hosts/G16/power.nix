{ config, lib, pkgs, ... }:

{
  # Power management configuration
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # TLP power management
  services.tlp = {
    enable = true;
    settings = {
      # CPU power management
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
      
      # SATA power management
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
      
      # PCIe power management
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      
      # Runtime Power Management for PCI(e) devices
      RUNTIME_PM_ON_AC = lib.mkForce "on";
      RUNTIME_PM_ON_BAT = lib.mkForce "on";
      RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau nvidia pcieport uhci_hcd xhci_hcd";
      
      # USB power management
      USB_AUTOSUSPEND = 0;  # Disabled to prevent mouse lag
      USB_DENYLIST = "046d:c53f 046d:c548";  # Common Logitech mouse IDs
      
      # Audio power management
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      
      # Wireless power management
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";
      WOL_DISABLE = "Y";
      
      # Platform specific settings
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };

  # Disable power-profiles-daemon as it conflicts with TLP
  services.power-profiles-daemon.enable = false;

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

  # Power management related packages
  environment.systemPackages = with pkgs; [
    powertop
    linuxPackages.cpupower
    tlp
  ];

  # Additional kernel parameters for power management
  boot.kernelParams = [ 
    "intel_pstate=active"
    "pcie_aspm=force"
    "i915.enable_psr=1"
    "i915.enable_fbc=1"
    "nmi_watchdog=0"
    "vm.dirty_writeback_centisecs=6000"
    "i915.enable_guc=3"
    "i915.enable_dc=2"
  ];

  # PCI power management
  services.udev.extraRules = ''
    # Enable PCI power management for all devices
    ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
    
    # Specific power management for Intel graphics
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
    
    # Power management for NVMe devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{class}=="0x010802", TEST=="power/control", ATTR{power/control}="auto"
    
    # Enable SATA link power management
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
    
    # Enable I2C adapter power management
    ACTION=="add", SUBSYSTEM=="i2c", TEST=="power/control", ATTR{power/control}="auto"
    
    # Enable runtime PM for Thunderbolt controllers
    ACTION=="add", SUBSYSTEM=="pci", ATTR{class}=="0x0c8000", TEST=="power/control", ATTR{power/control}="auto"
    
    # Enable runtime PM for USB controllers
    ACTION=="add", SUBSYSTEM=="pci", ATTR{class}=="0x0c0330", TEST=="power/control", ATTR{power/control}="auto"
    
    # Enable runtime PM for Audio devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{class}=="0x040300", TEST=="power/control", ATTR{power/control}="auto"
    
    # Disable wake-on-lan
    ACTION=="add", SUBSYSTEM=="net", NAME=="wlan*", RUN+="${pkgs.ethtool}/bin/ethtool -s $name wol d"
    
    # USB power management (exclude Logitech receiver)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}!="046d", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", TEST=="power/control", ATTR{power/control}="on"
    
    # Runtime PM for PCI devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", TEST=="power/control", ATTR{power/control}="auto"
    
    # Audio codec power management
    ACTION=="add", SUBSYSTEM=="sound", ATTR{power/control}="auto"
  '';

  # Runtime power management for nvidia
  hardware.nvidia.powerManagement = {
    enable = true;
    finegrained = true;
  };

  # Additional power saving services
  services.thermald.enable = true;
}
