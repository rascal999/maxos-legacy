{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.autossh;
in {
  options.maxos.tools.autossh = {
    enable = mkEnableOption "AutoSSH — automatically restart SSH sessions and tunnels";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      autossh
    ];
  };
}
