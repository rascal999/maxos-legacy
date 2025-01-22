{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    userSettings = {
      "terminal.integrated.defaultProfile.linux" = "bash";
      "keyboard.dispatch" = "keyCode";
    };
    keybindings = [
      {
        key = "ctrl+t";
        command = "-workbench.action.quickOpen";
      }
      {
        key = "ctrl+t";
        command = "claude.newChat";
      }
    ];
  };
}
