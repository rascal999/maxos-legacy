{ config, pkgs, lib, ... }:

{
  # Input configuration
  services.libinput = {
    enable = true;
    mouse.naturalScrolling = false;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      disableWhileTyping = true;
    };
  };

  # Common desktop hardware configuration
  hardware = {
    # Graphics
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Audio
    pulseaudio.enable = false; # Using pipewire instead
  };

  # Audio services
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Power management hardware settings
  services = {
    thermald.enable = true;
    tlp.enable = true;
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
}
