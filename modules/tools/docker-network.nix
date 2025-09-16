{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.tools.docker-network = {
    enable = mkEnableOption "Docker network creation service";
    
    networkName = mkOption {
      type = types.str;
      default = "ollama_network";
      description = "Name of the Docker network to create";
    };
  };

  config = mkIf config.modules.tools.docker-network.enable {
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
        ExecStart = "${pkgs.docker}/bin/docker network create ${config.modules.tools.docker-network.networkName} || true";
      };
    };
  };
}
