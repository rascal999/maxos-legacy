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
    # Note: Default modules are usually loaded automatically by the session manager (wireplumber)
    # "context.modules" = [ ]; # Keep empty or add only non-default modules if needed
  };

  # Add noise suppression and voice enhancement configuration for Anua Mic CM 900
  # This creates a drop-in config file at /etc/pipewire/pipewire.conf.d/99-input-denoising.conf
  services.pipewire.extraConfig.pipewire."99-input-denoising" = {
    context.modules = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          node.description = "Anua Mic CM 900 Enhanced";
          media.name = "Anua Mic CM 900 Enhanced";
          filter.graph = {
            nodes = [
              # First apply noise suppression
              {
                type = "ladspa";
                name = "noise_suppressor";
                plugin = "${pkgs.rnnoise}/lib/ladspa/librnnoise_ladspa.so";
                label = "noise_suppressor_mono";
                control = {
                  # Adjust these values as needed (0.0 to 1.0)
                  # Higher values = more aggressive noise reduction
                  "VAD Threshold (%)" = 50.0;
                  "VAD Grace Period (ms)" = 200;
                  "Retroactive VAD Grace (ms)" = 0;
                };
              }
              # Then apply a compressor to enhance voice clarity
              {
                type = "ladspa";
                name = "compressor";
                plugin = "${pkgs.ladspaPlugins}/lib/ladspa/sc4_1882.so";
                label = "sc4";
                control = {
                  # Threshold (dB)
                  "0" = -30.0;
                  # Ratio (1:n)
                  "1" = 3.0;
                  # Attack time (ms)
                  "2" = 10.0;
                  # Release time (ms)
                  "3" = 100.0;
                  # Knee radius (dB)
                  "4" = 3.0;
                  # Makeup gain (dB)
                  "5" = 6.0;
                };
              }
              # Finally apply a simple equalizer to boost voice frequencies
              {
                type = "ladspa";
                name = "eq";
                plugin = "${pkgs.ladspaPlugins}/lib/ladspa/mbeq_1197.so";
                label = "mbeq";
                control = {
                  # 50Hz (reduce low rumble)
                  "0" = -10.0;
                  # 100Hz
                  "1" = -5.0;
                  # 156Hz
                  "2" = -2.0;
                  # 220Hz
                  "3" = 0.0;
                  # 311Hz
                  "4" = 1.0;
                  # 440Hz
                  "5" = 2.0;
                  # 622Hz
                  "6" = 3.0;
                  # 880Hz (voice clarity)
                  "7" = 4.0;
                  # 1250Hz (voice clarity)
                  "8" = 5.0;
                  # 1750Hz (voice clarity)
                  "9" = 5.0;
                  # 2500Hz (voice clarity)
                  "10" = 4.0;
                  # 3500Hz
                  "11" = 2.0;
                  # 5000Hz
                  "12" = 0.0;
                  # 10000Hz
                  "13" = -2.0;
                  # 20000Hz
                  "14" = -4.0;
                };
              }
            ];
            links = [
              { output = "noise_suppressor:Output"; input = "compressor:Input"; }
              { output = "compressor:Output"; input = "eq:Input"; }
            ];
          };
          capture.props = {
            node.name = "capture.anua_mic_denoised";
            node.passive = true;
            audio.rate = 48000;
            node.target = "alsa_input.hw_0_0";  # Target the Anua Mic CM 900
            stream.dont-remix = true;
            node.description = "Anua Mic CM 900 (Denoised)";
          };
          playback.props = {
            node.name = "anua_mic_denoised";
            media.class = "Audio/Source";
            audio.rate = 48000;
            node.description = "Anua Mic CM 900 (Denoised)";
          };
        };
      }
    ];
  };

  # Audio control and debugging packages
  environment.systemPackages = with pkgs; [
    qpwgraph                  # PipeWire graph GUI
    easyeffects               # Audio effects for PipeWire
    helvum                    # PipeWire patchbay
    pipewire                  # PipeWire tools including pw-top
    wireplumber               # Session manager for PipeWire
    rnnoise                   # RNNoise noise suppression plugin
    ladspaPlugins             # LADSPA plugins for audio processing
    pulseaudio                # For pactl utility
    
    # Toggle script removed for now to simplify configuration
  ];

  # Configure Intel HDA power management
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
    options snd_hda_intel power_save_controller=N
  '';
}
