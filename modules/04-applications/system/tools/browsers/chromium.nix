{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.chromium;
in {
  options.maxos.tools.chromium = {
    enable = mkEnableOption "Chromium web browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      chromium
    ];
  };
}