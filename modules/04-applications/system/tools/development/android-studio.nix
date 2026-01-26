{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.android-studio;
in {
  options.maxos.tools.android-studio = {
    enable = mkEnableOption "Android Studio";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      android-studio
    ];
  };
}