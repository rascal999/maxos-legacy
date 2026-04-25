{ config, lib, pkgs, ... }:

{
  imports = [
    ./ollama.nix
    ./open-webui.nix
    ./fabric-ai.nix
    ./codex.nix
    ./llama-cpp.nix
    ./vllm.nix
  ];
}
