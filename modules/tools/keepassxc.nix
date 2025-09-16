{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.keepassxc;
in {
  options.modules.tools.keepassxc = {
    enable = mkEnableOption "KeePassXC password manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      keepassxc
    ];
  };
}
