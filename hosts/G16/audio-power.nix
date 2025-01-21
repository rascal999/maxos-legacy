{ config, lib, pkgs, ... }:

{
  # Audio power management configuration for PulseAudio
  hardware.pulseaudio = {
    daemon.config = {
      avoid-resampling = "yes";
      default-sample-rate = "48000";
      alternate-sample-rate = "44100";
      exit-idle-time = 5;
      high-priority = "yes";
      nice-level = -11;
      realtime-scheduling = "yes";
      realtime-priority = 9;
      rlimit-rtprio = 9;
      daemonize = "yes";
    };
  };
}
