# Stub module for alacritty - actual configuration handled by home-manager
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.alacritty;
in {
  options.maxos.tools.alacritty = {
    enable = mkEnableOption "Alacritty terminal emulator (via home-manager)";
  };

  config = mkIf cfg.enable {
    # Add alacritty to system packages for availability
    environment.systemPackages = with pkgs; [ alacritty ];
  };
}