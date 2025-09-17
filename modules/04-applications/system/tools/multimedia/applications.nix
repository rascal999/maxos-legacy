{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.multimedia-apps;
in {
  options.maxos.tools.multimedia-apps = {
    enable = mkEnableOption "Multimedia applications";
    
    includeVideo = mkOption {
      type = types.bool;
      default = true;
      description = "Include video player (VLC)";
    };
    
    includeImageEditing = mkOption {
      type = types.bool;
      default = true;
      description = "Include image editing tools (GIMP)";
    };
    
    includeOffice = mkOption {
      type = types.bool;
      default = true;
      description = "Include office suite (LibreOffice)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Always include basic multimedia tools
    ] ++ optionals cfg.includeVideo [
      vlc
    ] ++ optionals cfg.includeImageEditing [
      gimp
    ] ++ optionals cfg.includeOffice [
      libreoffice
    ];
  };
}