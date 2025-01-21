{ config, lib, pkgs, ... }:

{
  # Networking configuration
  networking = {
    # NetworkManager configuration
    networkmanager = {
      enable = true;
      wifi = {
        backend = "wpa_supplicant"; # More stable backend
        powersave = false;
      };
    };
    # Disable standalone wpa_supplicant
    wireless.enable = false;
  };

  # Load iwlwifi with correct power saving parameters
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 uapsd_disable=1
    options iwlmvm power_scheme=1
  '';

  # Enable better hardware support for Intel AX211
  hardware.enableAllFirmware = true;
}
