{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.ollama;
in {
  options.modules.tools.ollama = {
    enable = mkEnableOption "ollama";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
    };
  };
}
