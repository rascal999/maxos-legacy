{ config, lib, pkgs, ... }:

{
  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Custom configuration to help with speaker amp
    config.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 8192;
      };
    };

    # Audio settings specific to ROG laptops
    config.pipewire."context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Speaker Amp Enhancer";
          "media.name" = "Speaker Amp Enhancer";
          "filter.graph" = {
            nodes = [
              {
                type = "builtin";
                name = "mixer";
                control = {
                  "gain" = 1.0;
                };
              }
            ];
          };
        };
      }
    ];
  };

  # Additional audio packages
  environment.systemPackages = with pkgs; [
    pavucontrol  # PulseAudio Volume Control
    easyeffects  # Audio effects for PipeWire
    helvum       # PipeWire patchbay
  ];

  # Load ALSA UCM config for ROG laptops
  boot.extraModprobeConfig = ''
    options snd_hda_intel model=asus-zenbook
    options snd_hda_intel power_save=0
    options snd_hda_intel power_save_controller=N
  '';
}
