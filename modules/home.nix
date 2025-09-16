# Home-manager modules only - modules that use home.* or programs.* without system-level options
{ config, lib, pkgs, ... }:

{
  imports = [
    # Pure home-manager tool modules
    ./tools/alacritty.nix
    ./tools/claude-code.nix  
    ./tools/direnv.nix
    ./tools/logseq.nix
    ./tools/micromamba.nix
    ./tools/tmux.nix
    ./tools/vscode.nix
    # ./tools/vscode-unmanaged.nix  # Conflicts with vscode.nix
    ./tools/zsh.nix
  ];
}