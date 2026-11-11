{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.ghidra;
in {
  options.maxos.tools.ghidra = {
    enable = mkEnableOption "Ghidra reverse engineering suite";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ghidra
    ];
  };
}
