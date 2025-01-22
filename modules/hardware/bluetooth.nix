{ config, lib, pkgs, ... }:

{
  # Bluetooth configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable Bluetooth service and management
  services.blueman.enable = true;

  # Add Bluetooth utilities to system packages
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];
}
