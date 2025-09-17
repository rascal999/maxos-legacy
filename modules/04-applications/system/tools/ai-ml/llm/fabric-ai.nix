{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.fabric-ai;
in {
  options.maxos.tools.fabric-ai = {
    enable = mkEnableOption "fabric-ai";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fabric-ai
    ];

    # Add any additional configuration needed for fabric-ai
  };
}