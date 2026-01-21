{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.filezilla;
in {
  options.maxos.tools.filezilla = {
    enable = mkEnableOption "FileZilla FTP client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      filezilla
    ];
  };
}