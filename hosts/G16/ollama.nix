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

}