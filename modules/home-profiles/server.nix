# Common server home manager configuration  
{ config, lib, pkgs, ... }:

{
  imports = [
    ../tools/i3/server.nix
    ../tools/tmux.nix
    ../tools/alacritty.nix
    ../tools/zsh.nix
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Common server settings
  home = {
    stateVersion = "23.11";
  };

  # Server-focused programs
  programs = {
    # Terminal and shell essentials for server management
    alacritty.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
  };

  # Minimal services for server environment
  services = {
    # Server services will be configured by individual tool modules
  };
}