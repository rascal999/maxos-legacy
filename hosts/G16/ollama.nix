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

  # Override default ollama service configuration
  services.ollama.enable = lib.mkForce false;

  # Ollama configuration disabled - using system ollama service instead
  # Docker-based ollama setup was replaced with native NixOS ollama service
}