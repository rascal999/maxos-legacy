{ config, lib, pkgs, ... }:

{
  imports = [
    ./ollama.nix
    ./open-webui.nix
    ./fabric-ai.nix
    ./codex.nix
  ];
}
