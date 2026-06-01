{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.rtk;
in {
  options.maxos.tools.rtk = {
    enable = mkEnableOption "rtk (Rust Token Killer)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rtk
    ];
  };
}
