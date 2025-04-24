{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.pulseaudio-docker;
in {
  options.modules.tools.pulseaudio-docker = {
    enable = mkEnableOption "PulseAudio Docker integration";
  };

  config = mkIf cfg.enable {
    # Install PulseAudio
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      
      # Enable ALSA support
      support32Bit = true;
      
      # Configure PulseAudio to allow access from Docker containers
      extraConfig = ''
        # Allow PulseAudio to be accessed via the network (from containers)
        load-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/pulseaudio.socket
        
        # Allow applications in containers to play sounds
        load-module module-native-protocol-tcp auth-anonymous=1
      '';
    };
    
    # Create directory for PulseAudio socket
    systemd.tmpfiles.rules = [
      "d /tmp/pulse 0755 root root - -"
      "d /run/user/1000/pulse 0755 user users - -"
    ];
    
    # Add PulseAudio utilities
    environment.systemPackages = with pkgs; [
      pulseaudio
      pavucontrol
    ];
    
    # Add user to audio group
    users.users.user.extraGroups = [ "audio" ];
  };
}