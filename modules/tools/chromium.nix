{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.chromium;
in {
  options.modules.tools.chromium = {
    enable = mkEnableOption "Chromium web browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      chromium
    ];
  };
}