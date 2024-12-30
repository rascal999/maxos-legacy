{ config, pkgs, lib, ... }:

{
  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
    
    # High quality audio settings
    config.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 8192;
      };
    };
    
    # Better bluetooth audio
    config.pipewire-pulse = {
      "context.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.headset-roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  # User-specific audio configuration
  home-manager.users.user = { pkgs, ... }: {
    # EasyEffects for audio processing
    services.easyeffects = {
      enable = true;
      preset = "balanced";
    };

    # Audio control tools
    home.packages = with pkgs; [
      # Audio utilities
      pavucontrol
      helvum
      qpwgraph
      
      # Audio production
      ardour
      audacity
      
      # Media playback
      playerctl
      
      # Bluetooth audio
      bluez
      bluez-tools
    ];

    # Media controls
    services.playerctld.enable = true;

    # PipeWire configuration
    xdg.configFile = {
      # EasyEffects presets
      "easyeffects/output/balanced.json".text = ''
        {
          "output": {
            "blocklist": [],
            "plugins_order": [
              "limiter",
              "autogain",
              "equalizer"
            ],
            "equalizer": {
              "state": "true",
              "mode": "IIR",
              "num-bands": 10,
              "input-gain": 0,
              "output-gain": 0,
              "split-channels": false,
              "left": {
                "band0": {"type": "Lo-shelf", "freq": 32, "q": 0.707, "gain": 3},
                "band1": {"type": "Bell", "freq": 64, "q": 0.707, "gain": 2},
                "band2": {"type": "Bell", "freq": 125, "q": 0.707, "gain": 1},
                "band3": {"type": "Bell", "freq": 250, "q": 0.707, "gain": 0},
                "band4": {"type": "Bell", "freq": 500, "q": 0.707, "gain": -1},
                "band5": {"type": "Bell", "freq": 1000, "q": 0.707, "gain": 0},
                "band6": {"type": "Bell", "freq": 2000, "q": 0.707, "gain": 1},
                "band7": {"type": "Bell", "freq": 4000, "q": 0.707, "gain": 2},
                "band8": {"type": "Bell", "freq": 8000, "q": 0.707, "gain": 3},
                "band9": {"type": "Hi-shelf", "freq": 16000, "q": 0.707, "gain": 4}
              },
              "right": {
                "band0": {"type": "Lo-shelf", "freq": 32, "q": 0.707, "gain": 3},
                "band1": {"type": "Bell", "freq": 64, "q": 0.707, "gain": 2},
                "band2": {"type": "Bell", "freq": 125, "q": 0.707, "gain": 1},
                "band3": {"type": "Bell", "freq": 250, "q": 0.707, "gain": 0},
                "band4": {"type": "Bell", "freq": 500, "q": 0.707, "gain": -1},
                "band5": {"type": "Bell", "freq": 1000, "q": 0.707, "gain": 0},
                "band6": {"type": "Bell", "freq": 2000, "q": 0.707, "gain": 1},
                "band7": {"type": "Bell", "freq": 4000, "q": 0.707, "gain": 2},
                "band8": {"type": "Bell", "freq": 8000, "q": 0.707, "gain": 3},
                "band9": {"type": "Hi-shelf", "freq": 16000, "q": 0.707, "gain": 4}
              }
            },
            "limiter": {
              "state": "true",
              "input-gain": 0,
              "limit": 0,
              "lookahead": 5,
              "release": 50,
              "asc": true,
              "asc-level": 0.5,
              "oversampling": "None"
            },
            "autogain": {
              "state": "true",
              "input-gain": 0,
              "output-gain": 0,
              "target": -23,
              "weight-m": 1,
              "weight-s": 1,
              "weight-i": 1
            }
          }
        }
      '';
    };

    # Keyboard media keys
    services.sxhkd.keybindings = {
      "XF86AudioPlay" = "playerctl play-pause";
      "XF86AudioNext" = "playerctl next";
      "XF86AudioPrev" = "playerctl previous";
      "XF86AudioStop" = "playerctl stop";
      "XF86AudioRaiseVolume" = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
    };
  };
}
