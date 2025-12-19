{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.dig;
in {
  options.maxos.tools.dig = {
    enable = mkEnableOption "dig (DNS lookup utility)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bind.dnsutils
    ];
  };
}
