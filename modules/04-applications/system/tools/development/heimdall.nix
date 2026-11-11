{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.heimdall;
in {
  options.maxos.tools.heimdall = {
    enable = mkEnableOption "Heimdall (Samsung flashing tool, Odin equivalent)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      heimdall
    ];

    # heimdall talks to the Samsung Odin/download-mode USB interface
    # (vendor 04e8) directly via libusb. The package ships no udev rules and
    # android-udev-rules is removed in this nixpkgs, so grant access here.
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666"
    '';
  };
}
