{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.file;
in {
  options.maxos.tools.file = {
    enable = mkEnableOption "file (file type identification utility)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      file
    ];
  };
}
