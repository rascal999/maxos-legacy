{ config, lib, pkgs, ... }:

{
  # Service to create Docker network if it doesn't exist
  systemd.services.create-docker-network = {
    description = "Create Docker network if it doesn't exist";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];

    path = [ pkgs.bash pkgs.docker ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker network create ollama_network || true";
    };
  };
}
