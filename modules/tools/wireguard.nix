{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.wireguard;
in {
  options.modules.tools.wireguard = {
    enable = mkEnableOption "WireGuard VPN tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
  };
}