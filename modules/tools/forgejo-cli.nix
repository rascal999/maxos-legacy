{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.forgejo-cli;
in
{
  options.modules.tools.forgejo-cli = {
    enable = mkEnableOption "Forgejo CLI tool";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      forgejo-cli
    ];
  };
}