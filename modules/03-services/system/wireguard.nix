{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.wireguard;
in {
  options.maxos.tools.wireguard = {
    enable = mkEnableOption "WireGuard VPN tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
  };
}