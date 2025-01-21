{ config, lib, pkgs, ... }:

{
  # Enable PulseAudio
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    daemon.config = {
      default-sample-rate = "48000";
      default-fragments = "5";
      default-fragment-size-msec = "2";
      resample-method = "speex-float-5";
      flat-volumes = "no";
      realtime-scheduling = "yes";
      avoid-resampling = "yes";
      alternate-sample-rate = "44100";
      exit-idle-time = "5";
      high-priority = "yes";
      nice-level = "-11";
      realtime-priority = "9";
      rlimit-rtprio = "9";
      daemonize = "yes";
    };
    # Configure for ROG laptop
    extraConfig = ''
      load-module module-udev-detect
      load-module module-native-protocol-unix
      load-module module-alsa-card device_id="0" name="pci-0000_00_1f.3" card_name="alsa_card.pci-0000_00_1f.3" tsched=yes fixed_latency_range=yes
      set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
      set-sink-volume alsa_output.pci-0000_00_1f.3.analog-stereo 40000
    '';
  };

  # Disable PipeWire
  services.pipewire.enable = false;

  # Audio control packages
  environment.systemPackages = with pkgs; [
    pavucontrol  # PulseAudio Volume Control
    pamixer      # Command line mixer for PulseAudio
    pulsemixer   # CLI and curses mixer for PulseAudio
  ];

  # Load ALSA UCM config for ROG laptops
  boot.extraModprobeConfig = ''
    options snd_hda_intel model=asus-zenbook
    options snd_hda_intel power_save=0
    options snd_hda_intel power_save_controller=N
  '';
}
