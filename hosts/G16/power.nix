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
      
      # SATA power management
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
      
      # PCIe power management
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      
      # Runtime Power Management for PCI(e) devices
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      
      # USB autosuspend
      USB_AUTOSUSPEND = 1;
      USB_DENYLIST = "3-3"; # Exclude Logitech USB receiver
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_BTUSB = 1;
      USB_EXCLUDE_PHONE = 1;
      USB_EXCLUDE_PRINTER = 1;
      
      # Audio power management
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      
      # Wireless power management
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      WOL_DISABLE = "Y";
      
      # Platform specific settings
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };

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
    # Enable PCI power management
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    
    # Enable SATA link power management
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
    
    # Enable I2C adapter power management
    ACTION=="add", SUBSYSTEM=="i2c", TEST=="power/control", ATTR{power/control}="auto"
    
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
}
