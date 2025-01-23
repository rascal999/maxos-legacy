{ config, lib, pkgs, ... }:

{
  # Service to create Docker network if it doesn't exist
  systemd.services.create-docker-network = {
    description = "Create Docker network if it doesn't exist";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${../../scripts/create-docker-network.sh}";
    };
  };
}
