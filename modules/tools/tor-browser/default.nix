{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.tools.tor-browser;
in
{
  options.modules.tools.tor-browser = {
    enable = mkEnableOption "tor-browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tor-browser
    ];
  };
}