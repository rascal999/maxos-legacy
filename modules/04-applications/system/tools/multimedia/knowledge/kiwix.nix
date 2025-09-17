{ config, pkgs, lib, ... }:

with lib;

{
  options.maxos.tools.kiwix = {
    enable = mkEnableOption "Kiwix offline content reader";
  };

  config = mkIf config.maxos.tools.kiwix.enable {
    environment.systemPackages = with pkgs; [
      kiwix
      kiwix-tools
    ];
  };
}