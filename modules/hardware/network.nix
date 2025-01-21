{ config, lib, pkgs, ... }:

{
  # Networking configuration
  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd"; # Modern WiFi backend
    };
    wireless.enable = false; # Disable wpa_supplicant in favor of NetworkManager
  };

  # IWD configuration
  services.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = false;
        AddressRandomization = "network";
        AddressRandomizationRange = "full";
      };
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Settings = {
        AutoConnect = true;
      };
    };
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
