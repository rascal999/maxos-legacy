{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.zed-editor;

  dependenciesValid =
    config.maxos.user.enable or true;

in {
  options.maxos.tools.zed-editor = {
    enable = mkEnableOption "Zed code editor";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    home.packages = [ pkgs.zed-editor ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "zed-editor requires the user module to be enabled";
      }
    ];
  };
}