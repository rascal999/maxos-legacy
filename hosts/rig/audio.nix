{ config, lib, pkgs, ... }:

{
  # Enable PipeWire (pure PipeWire, no compatibility layers)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  # Audio control and debugging packages
  environment.systemPackages = with pkgs; [
    qpwgraph                  # PipeWire graph GUI
    easyeffects               # Audio effects for PipeWire
    helvum                    # PipeWire patchbay
    pipewire                  # PipeWire tools including pw-top
    wireplumber               # Session manager for PipeWire
    pulseaudio                # For pactl utility
  ];

  # Configure Intel HDA power management
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
    options snd_hda_intel power_save_controller=N
  '';
}
