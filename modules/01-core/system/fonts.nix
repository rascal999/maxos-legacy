{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.fonts;
in {
  options.maxos.fonts = {
    enable = mkEnableOption "Centralized font management";
    
    primary = mkOption {
      type = types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Primary font family for UI and terminals";
    };
    
    fallback = mkOption {
      type = types.str;
      default = "MesloLG Nerd Font";
      description = "Fallback font family";
    };
    
    size = {
      default = mkOption {
        type = types.int;
        default = 11;
        description = "Default font size";
      };
      
      small = mkOption {
        type = types.int;
        default = 9;
        description = "Small font size";
      };
      
      large = mkOption {
        type = types.int;
        default = 14;
        description = "Large font size";
      };
    };
    
    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
      ];
      description = "Font packages to install";
    };
  };

  config = mkIf cfg.enable {
    # Install font packages
    fonts.packages = cfg.packages;
    
    # System-wide font configuration
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ cfg.primary cfg.fallback ];
        # Use system defaults for sansSerif to avoid affecting browsers
        sansSerif = [ "DejaVu Sans" "Liberation Sans" "sans-serif" ];
      };
    };
  };
}