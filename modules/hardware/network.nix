{ config, lib, pkgs, ... }:

{
  # Networking configuration
  networking = {
    # NetworkManager configuration
    networkmanager = {
      enable = true;
      wifi = {
        backend = "iwd"; # Modern WiFi backend
        powersave = false; # Disable WiFi power management
      };
    };
    # Disable wpa_supplicant in favor of NetworkManager
    wireless.enable = false;
  };

  # Disable power management for wireless interfaces
  services.udev.extraRules = lib.mkForce ''
    # Disable power management for wireless interfaces
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save off"
  '';

  # Load iwlwifi with power saving disabled
  boot.extraModprobeConfig = lib.mkForce ''
    options iwlwifi power_save=0 d0i3_disable=1 uapsd_disable=1
    options iwlmvm power_scheme=1
  '';
}
