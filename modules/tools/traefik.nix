{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.traefik;
in {
  options.modules.tools.traefik = {
    enable = mkEnableOption "Traefik API Gateway";
  };

  config = mkIf cfg.enable {
    # Ensure docker is enabled
    virtualisation.docker.enable = true;

    # Create systemd service for Traefik
    systemd.services.traefik = {
      description = "Traefik API Gateway";
      wantedBy = [ "multi-user.target" ];
      requires = [ "docker.service" ];
      after = [ "docker.service" ];

      # Create traefik-public network before starting
      preStart = ''
        ${pkgs.docker}/bin/docker network create traefik-public || true
      '';

      # Start Traefik using docker compose
      script = ''
        cd /home/user/git/github/monorepo/docker/traefik
        ${pkgs.docker-compose}/bin/docker-compose up
      '';

      # Cleanup on stop
      postStop = ''
        cd /home/user/git/github/monorepo/docker/traefik
        ${pkgs.docker-compose}/bin/docker-compose down
      '';

      # Service configuration
      serviceConfig = {
        Type = "simple";
        User = "user";
        Group = "docker";
        Restart = "always";
        RestartSec = "10";
      };
    };

    # Start example service
    systemd.services.traefik-example = {
      description = "Traefik Example Service";
      wantedBy = [ "multi-user.target" ];
      requires = [ "traefik.service" ];
      after = [ "traefik.service" ];

      script = ''
        cd /home/user/git/github/monorepo/docker/traefik
        ${pkgs.docker-compose}/bin/docker-compose -f example-service.yml up
      '';

      postStop = ''
        cd /home/user/git/github/monorepo/docker/traefik
        ${pkgs.docker-compose}/bin/docker-compose -f example-service.yml down
      '';

      serviceConfig = {
        Type = "simple";
        User = "user";
        Group = "docker";
        Restart = "always";
        RestartSec = "10";
      };
    };

    # Install required packages
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}