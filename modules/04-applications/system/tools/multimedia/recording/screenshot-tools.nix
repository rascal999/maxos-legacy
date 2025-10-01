{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.screenshot-tools;
in {
  options.maxos.tools.screenshot-tools = {
    enable = mkEnableOption "Enable screenshot tools (maim and scrot)";
    
    enableMaim = mkOption {
      type = types.bool;
      default = true;
      description = "Enable maim screenshot tool";
    };
    
    enableScrot = mkOption {
      type = types.bool;
      default = true;
      description = "Enable scrot screenshot tool";
    };
    
    enableXclip = mkOption {
      type = types.bool;
      default = true;
      description = "Enable xclip for clipboard support";
    };
  };

  config = mkIf cfg.enable {
    # Install screenshot tools
    environment.systemPackages = with pkgs;
      (optionals cfg.enableMaim [ maim ]) ++
      (optionals cfg.enableScrot [ scrot ]) ++
      (optionals cfg.enableXclip [ xclip ]);
  };
}