{ config, lib, pkgs, ... }:

{
  # Enable PipeWire (pure PipeWire, no compatibility layers)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # WirePlumber configuration to prioritize Bluetooth devices
  services.pipewire.wireplumber.extraConfig = {
    "10-bluetooth-policy" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.headset-roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" "a2dp_sink" "a2dp_source" ];
      };
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = true;
      };
    };
    "11-bluetooth-priority" = {
      "monitor.bluez.rules" = [
        {
          matches = [
            {
              "node.name" = "~bluez_output.*";
            }
          ];
          actions = {
            update-props = {
              "priority.session" = 2000; # Higher than USB (1100)
              "priority.driver" = 2000;
            };
          };
        }
      ];
    };
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
