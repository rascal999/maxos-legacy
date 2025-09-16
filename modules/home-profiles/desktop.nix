# Common desktop home manager configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ../tools/i3/desktop.nix
    ../tools/rofi/default.nix
    ../tools/firefox/default.nix
    ../tools/alacritty.nix
    ../tools/zsh.nix
    ../tools/tmux.nix
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Common desktop settings
  home = {
    stateVersion = "23.11";
  };

  # Common desktop programs
  programs = {
    # Browser
    firefox.enable = lib.mkDefault true;
    
    # Terminal and shell
    alacritty.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
  };

  # Common desktop services
  services = {
    # Desktop services will be configured by individual tool modules
  };
}