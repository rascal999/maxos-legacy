{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.just;
in {
  options.maxos.tools.just = {
    enable = mkEnableOption "Just command runner";
  };

  config = mkIf cfg.enable {
    # Install Just package
    environment.systemPackages = with pkgs; [
      just
    ];
  };
}