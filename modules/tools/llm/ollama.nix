{ config, lib, pkgs, ... }:

{
  # Enable Docker with NVIDIA support
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    daemon.settings = lib.mkForce {
      default-runtime = "nvidia";
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
          runtimeArgs = [];
        };
      };
    };
  };

  # Add NVIDIA Container Runtime
  virtualisation.containerd = {
    enable = true;
    settings = {
      plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia = {
        runtime_type = "io.containerd.runc.v2";
        options = {
          BinaryName = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        };
      };
    };
  };

  # Configure Ollama service
  services.ollama.enable = false;

  # systemd.services.ollama = lib.mkForce {
  #   description = "Ollama LLM Service (Docker)";
  #   wantedBy = [ "multi-user.target" ];
  #   requires = [ "docker.service" "network-online.target" ];
  #   after = [ "docker.service" "network-online.target" ];
  #
  #   serviceConfig = {
  #     Type = "exec";
  #     TimeoutStartSec = "10m";
  #     Restart = "on-failure";
  #     RestartSec = "30s";
  #     ExecStartPre = [
  #       "+${pkgs.bash}/bin/bash -c 'until ${pkgs.docker}/bin/docker pull ollama/ollama:latest; do echo Retrying pull in 30s; sleep 30; done'"
  #       ''${pkgs.docker}/bin/docker rm -f ollama || true''
  #     ];
  #     ExecStart = ''
  #       ${pkgs.docker}/bin/docker run \
  #         --name ollama \
  #         --runtime=nvidia \
  #         --gpus 'all,"capabilities=compute,utility"' \
  #         -e NVIDIA_VISIBLE_DEVICES=all \
  #         -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics \
  #         -e OLLAMA_DEBUG=1 \
  #         -e OLLAMA_DISABLE_CPU=true \
  #         -e OLLAMA_KV_CACHE_TYPE=q8_0 \
  #         -v ollama:/root/.ollama \
  #         -p 11434:11434 \
  #         -e OLLAMA_KEEP_ALIVE=-1 \
  #         --rm \
  #         ollama/ollama
  #     '';
  #     ExecStop = "${pkgs.docker}/bin/docker stop ollama";
  #   };
  # };

  # Create Docker volume for persistence
  # systemd.services.ollama-volume-setup = {
  #   description = "Setup Ollama Docker volume";
  #   wantedBy = [ "multi-user.target" ];
  #   requires = [ "docker.service" ];
  #   after = [ "docker.service" ];
  #   before = [ "ollama.service" ];
  #
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.docker}/bin/docker volume create ollama";
  #   };
  # };

  # Service to load deepseek model on boot
  # systemd.services.ollama-load-deepseek = {
  #   description = "Load deepseek-r1:14b model in Ollama";
  #   wantedBy = [ "multi-user.target" ];
  #   requires = [ "ollama.service" ];
  #   after = [ "ollama.service" ];
  #
  #   path = [ pkgs.bash pkgs.curl ];
  #
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${../../../scripts/load-ollama-model.sh}";
  #     Restart = "on-failure";
  #     RestartSec = "30s";
  #   };
  # };

  # Network creation service moved to a separate module
}
