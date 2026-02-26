{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.docker-buildx;
  dependenciesValid = config.maxos.tools.docker.enable or false;
in {
  options.maxos.tools.docker-buildx = {
    enable = mkEnableOption "Docker Buildx CLI plugin";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "docker-buildx requires maxos.tools.docker to be enabled";
      }
    ];

    environment.systemPackages = with pkgs; [
      docker-buildx
    ];

    # Configure docker-buildx as a CLI plugin
    # NixOS's docker-buildx package usually handles this, but we ensure the directory exists
    system.activationScripts.docker-buildx-plugin = ''
      mkdir -p /usr/lib/docker/plugins
      ln -sf ${pkgs.docker-buildx}/bin/docker-buildx /usr/lib/docker/plugins/docker-buildx
    '';
  };
}
