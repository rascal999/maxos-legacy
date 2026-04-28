{ config, lib, pkgs, ... }:

{
  options.maxos.tools.web-ext = {
    enable = lib.mkEnableOption "web-ext Mozilla extension CLI tool";
  };

  config = lib.mkIf config.maxos.tools.web-ext.enable {
    environment.systemPackages = with pkgs; [
      web-ext
    ];
  };
}
