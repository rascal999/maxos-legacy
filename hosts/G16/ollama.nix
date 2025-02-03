{ config, lib, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      default-runtime = "nvidia";
      runtimes = {
        nvidia = {
          path = lib.mkForce "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
          runtimeArgs = [];
        };
      };
    };
  };

  # Remove default ollama service to avoid conflicts
  services.ollama.enable = false;

  # Create Docker network for ollama
  systemd.services.ollama-network-setup = {
    description = "Setup Ollama Docker network";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    before = [ "ollama.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c \"${pkgs.docker}/bin/docker network create ollama_network || true\"";
    };
  };

  # Create Docker volume for persistence
  systemd.services.ollama-volume-setup = {
    description = "Setup Ollama Docker volume";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    before = [ "ollama.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker volume create ollama";
    };
  };

  # Configure Ollama service
  systemd.services.ollama = {
    description = "Ollama LLM Service (Docker)";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" "ollama-network-setup.service" "ollama-volume-setup.service" ];
    after = [ "docker.service" "ollama-network-setup.service" "ollama-volume-setup.service" ];

    serviceConfig = {
      Type = "exec";
      ExecStartPre = [
        "${pkgs.docker}/bin/docker pull ollama/ollama:latest"
        ''${pkgs.docker}/bin/docker rm -f ollama || true''
      ];
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --name ollama \
          --runtime=nvidia \
          --gpus all \
          -e NVIDIA_VISIBLE_DEVICES=all \
          -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
          -e OLLAMA_DEBUG=1 \
          -e OLLAMA_DISABLE_CPU=true \
          -e OLLAMA_KV_CACHE_TYPE=q8_0 \
          -v ollama:/root/.ollama \
          -p 11434:11434 \
          -e OLLAMA_KEEP_ALIVE=-1 \
          --network ollama_network \
          --rm \
          ollama/ollama
      '';
      ExecStop = "${pkgs.docker}/bin/docker stop ollama";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}