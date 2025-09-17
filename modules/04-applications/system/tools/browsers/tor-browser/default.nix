{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.maxos.tools.tor-browser;
in
{
  options.maxos.tools.tor-browser = {
    enable = mkEnableOption "tor-browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tor-browser
    ];
  };
}