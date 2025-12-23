{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.knot-dns;
in {
  options.maxos.tools.knot-dns = {
    enable = mkEnableOption "Knot DNS (authoritative-only DNS server)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      knot-dns
    ];
  };
}