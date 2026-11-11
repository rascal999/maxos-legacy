{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.adb;
in {
  options.maxos.tools.adb = {
    enable = mkEnableOption "Android Debug Bridge (adb/fastboot)";
  };

  config = mkIf cfg.enable {
    # android-tools provides adb and fastboot. Device access needs no extra
    # udev setup: systemd 258 grants the active user access to uaccess-tagged
    # Android devices automatically (programs.adb and android-udev-rules are
    # removed in this nixpkgs release).
    environment.systemPackages = with pkgs; [
      android-tools
    ];
  };
}
