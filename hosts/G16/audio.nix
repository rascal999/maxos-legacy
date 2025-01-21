{ config, lib, pkgs, ... }:

{
  # Enable PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Basic PipeWire configuration
  services.pipewire.extraConfig.pipewire = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 1024;
      "default.clock.max-quantum" = 2048;
    };
  };

  # Simple audio configuration
  services.pipewire.extraConfig.pipewire-pulse = {
    "context.modules" = [
      {
        name = "libpipewire-module-protocol-pulse";
        args = {};
      }
    ];
    "stream.properties" = {
      "resample.quality" = 4;
    };
    "pulse.properties" = {
      "server.address" = [ "unix:native" ];
    };
  };

  # Audio control and debugging packages
  environment.systemPackages = with pkgs; [
    pavucontrol      # Volume control GUI
    easyeffects      # Audio effects for PipeWire
    helvum           # PipeWire patchbay
    pipewire         # PipeWire tools including pw-top
    qjackctl        # JACK control GUI
    wireplumber      # Session manager for PipeWire
  ];

  # Load ALSA UCM config for ROG laptops
  boot.extraModprobeConfig = ''
    options snd_hda_intel model=asus-zenbook
    options snd_hda_intel power_save=0
    options snd_hda_intel power_save_controller=N
  '';
}
