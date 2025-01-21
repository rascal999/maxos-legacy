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

  # Basic PipeWire configuration optimized for ROG laptop
  services.pipewire.extraConfig.pipewire = {
    "context.properties" = {
      "default.clock.rate" = "48000";
      "default.clock.quantum" = "1024";
      "default.clock.min-quantum" = "1024";
      "default.clock.max-quantum" = "2048";
      "core.daemon" = true;
      "core.version" = "3";
      "default.clock.power-save" = lib.mkForce false;
    };
  };

  # Simple audio processing configuration
  services.pipewire.extraConfig.pipewire-pulse = {
    "stream.properties" = {
      "resample.quality" = 4;
    };
    "pulse.properties" = {
      "server.address" = [ "unix:native" ];
      "pulse.min.quantum" = "1024/48000";
      "pulse.default.format" = "F32";
      "pulse.default.rate" = "48000";
      "pulse.default.channels" = "2";
    };
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
