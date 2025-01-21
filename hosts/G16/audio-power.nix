{ config, lib, pkgs, ... }:

{
  # Audio power management configuration
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    config.pipewire = {
      "context.properties" = {
        "default.clock.power-save" = true;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-protocol-native";
          args = {
            "audio.suspend-timeout" = 5;
          };
        }
      ];
    };
  };
}
