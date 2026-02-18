{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.input-leap;
  
in {
  options.maxos.tools.input-leap = {
    enable = mkEnableOption "input-leap (KVM software)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      input-leap
    ];
  };
}
