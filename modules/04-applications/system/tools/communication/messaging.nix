{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.communication;
in {
  options.maxos.tools.communication = {
    enable = mkEnableOption "Communication and messaging applications";
    
    includeSlack = mkOption {
      type = types.bool;
      default = true;
      description = "Include Slack messaging application";
    };
    
    includeDiscord = mkOption {
      type = types.bool;
      default = true;
      description = "Include Discord messaging application";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Communication tools
    ] ++ optionals cfg.includeSlack [
      slack
    ] ++ optionals cfg.includeDiscord [
      discord
    ];
  };
}