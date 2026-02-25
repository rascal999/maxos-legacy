{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.watchexec;
in {
  options.maxos.tools.watchexec = {
    enable = mkEnableOption "Watchexec - Execute commands when watched files change";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      watchexec
    ];
  };
}
