{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.anythingllm;
  anythingllmPath = "/home/user/git/github/monorepo/tools/anythingllm";
in {
  options.modules.tools.anythingllm = {
    enable = mkEnableOption "anythingllm";
    port = mkOption {
      type = types.port;
      default = 4000;
      description = "Port to run AnythingLLM on";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.anythingllm = {
      description = "AnythingLLM Service";
      wantedBy = [ "multi-user.target" ];
      requires = [
        "docker.service"
        "ollama.service"
        "network-online.target"
      ];
      after = [
        "docker.service"
        "ollama.service"
        "network-online.target"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = anythingllmPath;
        TimeoutStartSec = "20m";
        TimeoutStopSec = "5m";
        Restart = "on-failure";
        RestartSec = "30s";
        ExecStart = "/run/current-system/sw/bin/docker-compose -f ${anythingllmPath}/docker-compose.yml up -d";
        ExecStop = "/run/current-system/sw/bin/docker-compose -f ${anythingllmPath}/docker-compose.yml down";
      };
    };

    # Ensure Docker is enabled
    virtualisation.docker.enable = true;
    
    # Use the new option for NVIDIA container toolkit instead of the deprecated one
    hardware.nvidia-container-toolkit.enable = config.virtualisation.docker.enableNvidia;
  };
}