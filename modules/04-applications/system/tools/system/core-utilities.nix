{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.system-utilities;
in {
  options.maxos.tools.system-utilities = {
    enable = mkEnableOption "Core system utilities";
    
    includeMonitoring = mkOption {
      type = types.bool;
      default = true;
      description = "Include system monitoring tools (htop, btop, neofetch)";
    };
    
    includeArchiving = mkOption {
      type = types.bool;
      default = true;
      description = "Include archiving tools (unzip, zip)";
    };
    
    includeNetworking = mkOption {
      type = types.bool;
      default = true;
      description = "Include networking tools (wget, curl)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Always include basic utilities
    ] ++ optionals cfg.includeMonitoring [
      htop
      btop
      neofetch
    ] ++ optionals cfg.includeArchiving [
      unzip
      zip
    ] ++ optionals cfg.includeNetworking [
      wget
      curl
    ];
  };
}