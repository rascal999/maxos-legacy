{ config, pkgs, ... }:

{
  services.docker = {
    enable = true;
    daemon = {
      group = "docker";
    };
  };
}