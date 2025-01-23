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
  services.ollama.enable = true;

  systemd.services.ollama = lib.mkForce {
    description = "Ollama LLM Service (Docker)";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];

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
          -v ollama:/root/.ollama \
          -p 11434:11434 \
          --rm \
          ollama/ollama
      '';
      ExecStop = "${pkgs.docker}/bin/docker stop ollama";
      Restart = "always";
      RestartSec = "10s";
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

  # Add required NVIDIA packages
  environment.systemPackages = with pkgs; [
    nvidia-docker
    nvidia-container-toolkit
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
  ];

  # Open firewall port for Ollama
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
