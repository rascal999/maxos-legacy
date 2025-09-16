# Common development home manager configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./desktop.nix  # Include desktop base
    ../tools/vscode.nix
    ../tools/micromamba.nix
    ../tools/direnv.nix
    ../tools/git-hybrid.nix
  ];

  # Development-specific programs
  programs = {
    # Development tools
    git.enable = lib.mkDefault true;
    vscode.enable = lib.mkDefault true;
  };

  # Development environment variables
  home.sessionVariables = {
    EDITOR = lib.mkDefault "code";
    BROWSER = lib.mkDefault "firefox";
  };
}