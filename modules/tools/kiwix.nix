{ config, pkgs, lib, ... }:

with lib;

{
  options.modules.tools.kiwix = {
    enable = mkEnableOption "Kiwix offline content reader";
  };

  config = mkIf config.modules.tools.kiwix.enable {
    environment.systemPackages = with pkgs; [
      kiwix
      kiwix-tools
    ];
  };
}