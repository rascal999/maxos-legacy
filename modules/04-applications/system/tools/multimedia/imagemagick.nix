{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.imagemagick;
  
  # Layer 4 module - depends on core (Layer 1)
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.imagemagick = {
    enable = mkEnableOption "ImageMagick";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      imagemagick
    ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "imagemagick requires core user module";
      }
    ];
  };
}
