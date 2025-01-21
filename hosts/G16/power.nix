{ config, lib, pkgs, ... }:

{
  # Power management configuration
  powerManagement = {
    enable = true;
    powertop.enable = true;
    scsiLinkPolicy = "med_power_with_dipm";
  };

  # Additional kernel parameters for power management
  boot.kernelParams = [ 
    "intel_pstate=active"
    "pcie_aspm=force"
    "i915.enable_psr=1"
    "i915.enable_fbc=1"
    "nmi_watchdog=0"
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
  '';

  # Runtime power management for nvidia
  hardware.nvidia.powerManagement = {
    enable = true;
    finegrained = true;
  };
}
