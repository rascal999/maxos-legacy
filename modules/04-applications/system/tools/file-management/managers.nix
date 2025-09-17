{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.file-management;
in {
  options.maxos.tools.file-management = {
    enable = mkEnableOption "File management tools";
    
    includeGraphical = mkOption {
      type = types.bool;
      default = true;
      description = "Include graphical file manager (PCManFM)";
    };
    
    includeTerminal = mkOption {
      type = types.bool;
      default = true;
      description = "Include terminal file manager (Ranger)";
    };
    
    includeImageViewer = mkOption {
      type = types.bool;
      default = true;
      description = "Include lightweight image viewer (feh)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # File management tools
    ] ++ optionals cfg.includeGraphical [
      pcmanfm
    ] ++ optionals cfg.includeTerminal [
      ranger
    ] ++ optionals cfg.includeImageViewer [
      feh
    ];
  };
}