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
}
