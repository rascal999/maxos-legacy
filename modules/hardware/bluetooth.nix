{ config, lib, pkgs, ... }:

{
  # Bluetooth configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        AutoConnect = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 7;
        ReconnectIntervals = "1,2,4,8,16,32,64";
      };
    };
  };

  # Enable Bluetooth service and management
  services.blueman.enable = true;

  # Add Bluetooth utilities to system packages
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];
}
