{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    # No userSettings, extensions, or keybindings defined here
    # This allows VS Code to manage its own settings.json file
  };
}