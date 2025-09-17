{ config, pkgs, lib, ... }:

with lib;

{
  options.maxos.tools.postman = {
    enable = mkEnableOption "Postman API Client";
  };

  config = mkIf config.maxos.tools.postman.enable {
    environment.systemPackages = with pkgs; [
      postman
    ];

    # Enable AppImage support since Postman is distributed as an AppImage
    boot.supportedFilesystems = [ "fuse" ];
    boot.kernelModules = [ "fuse" ];
  };
}