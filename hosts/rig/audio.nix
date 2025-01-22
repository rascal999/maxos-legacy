{ config, lib, pkgs, ... }:

{
  # Enable PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
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

  # Audio control and debugging packages
  environment.systemPackages = with pkgs; [
    qpwgraph        # PipeWire graph GUI
    easyeffects     # Audio effects for PipeWire
    helvum          # PipeWire patchbay
    pipewire        # PipeWire tools including pw-top
    wireplumber     # Session manager for PipeWire
  ];

  # Configure Intel HDA power management
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
    options snd_hda_intel power_save_controller=N
  '';
}
