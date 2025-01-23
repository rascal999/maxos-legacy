{ config, lib, pkgs, ... }:

{
  imports = [
    ./ollama.nix
    ./open-webui.nix
    ../docker-network.nix
  ];
}
