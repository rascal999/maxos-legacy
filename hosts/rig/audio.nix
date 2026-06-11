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
    # Force the pro-audio profile on the Jieli wireless mic receiver.
    # The device only has "off" and "pro-audio" profiles; WirePlumber never
    # auto-selects "pro-audio" (priority 1) so the device stays on "off" and
    # no PipeWire source nodes are created. Setting device.profile.name here
    # makes WirePlumber activate "pro-audio" on every enumeration, which creates
    # alsa_input.usb-Jieli_...-00.pro-input-0 as the capture source.
    "12-jieli-pro-audio" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "device.name" = "alsa_card.usb-Jieli_Technology_USB_Composite_Device_433130393139312E-00";
            }
          ];
          actions = {
            update-props = {
              "device.profile.name" = "pro-audio";
            };
          };
        }
      ];
    };
  };

  # Keep Jieli wireless mic receiver's ALSA PCM permanently open so the
  # wireless link never drops. A pw-record consumer connected after WirePlumber
  # has fully enumerated the ALSA nodes keeps the source in RUNNING state,
  # preventing the ~6s firmware re-sync on next use.

  # Audio control and debugging packages
  environment.systemPackages = with pkgs; [
    qpwgraph                  # PipeWire graph GUI
    easyeffects               # Audio effects for PipeWire
    crosspipe                 # PipeWire patchbay (replaces helvum)
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
