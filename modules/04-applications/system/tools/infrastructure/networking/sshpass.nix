{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.sshpass;
in {
  options.maxos.tools.sshpass = {
    enable = mkEnableOption "sshpass — non-interactive SSH password authentication for scripted installs";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sshpass
    ];
  };
}
