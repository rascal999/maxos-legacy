{ config, lib, pkgs, ... }:

{
  # Disable PulseAudio and enable PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # PipeWire configuration for ROG laptop speakers
  services.pipewire.extraConfig.pipewire = {
    "context.properties" = {
      "default.clock.rate" = "48000";
      "default.clock.quantum" = "256";
      "default.clock.min-quantum" = "32";
      "default.clock.max-quantum" = "512";
      "default.clock.allowed-rates" = [ "44100" "48000" "88200" "96000" ];
      "core.daemon" = true;
      "core.version" = "3";
    };
  };

  # Audio processing configuration
  services.pipewire.extraConfig.pipewire-pulse = {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Audio Processor";
          "media.name" = "Audio Processor";
          "filter.graph" = {
            nodes = [
              {
                type = "builtin";
                name = "mixer";
                control = {
                  "gain" = "1.0";
                  "ramp-samples" = "32";
                };
              }
            ];
          };
          "capture.props" = {
            "node.name" = "effect_input.audio_processor";
            "audio.rate" = "48000";
            "audio.channels" = "2";
            "audio.position" = [ "FL" "FR" ];
          };
          "playback.props" = {
            "node.name" = "effect_output.audio_processor";
            "audio.rate" = "48000";
            "audio.channels" = "2";
            "audio.position" = [ "FL" "FR" ];
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
