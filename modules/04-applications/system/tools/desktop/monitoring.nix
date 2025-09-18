{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.desktop-monitoring;
in {
  options.maxos.tools.desktop-monitoring = {
    enable = mkEnableOption "Desktop monitoring and control tools";
    
    includeMediaControl = mkOption {
      type = types.bool;
      default = true;
      description = "Include media control tools (playerctl)";
    };
    
    includeNetworkManager = mkOption {
      type = types.bool;
      default = true;
      description = "Include NetworkManager applet";
    };
    
    includeDisplayTools = mkOption {
      type = types.bool;
      default = true;
      description = "Include display configuration tools (arandr)";
    };
    
    includeBrightnessControl = mkOption {
      type = types.bool;
      default = true;
      description = "Include brightness control (brightnessctl)";
    };
    
    includeAudioTray = mkOption {
      type = types.bool;
      default = true;
      description = "Include PipeWire volume control (pwvucontrol)";
    };
    
    includeRedshift = mkOption {
      type = types.bool;
      default = true;
      description = "Include blue light filter (redshift)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Desktop monitoring and control tools
    ] ++ optionals cfg.includeMediaControl [
      playerctl
    ] ++ optionals cfg.includeNetworkManager [
      networkmanagerapplet
    ] ++ optionals cfg.includeDisplayTools [
      arandr
    ] ++ optionals cfg.includeBrightnessControl [
      brightnessctl
    ] ++ optionals cfg.includeAudioTray [
      pwvucontrol
    ] ++ optionals cfg.includeRedshift [
      redshift
    ];
  };
}