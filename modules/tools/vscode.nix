{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    userSettings = {
      "terminal.integrated.defaultProfile.linux" = "bash";
      "keyboard.dispatch" = "keyCode";
      "vim.useSystemClipboard" = true;
      "editor.lineNumbers" = "relative";
      "vim.hlsearch" = true;
      "vim.insertModeKeyBindings" = [];
      "vim.normalModeKeyBindings" = [];
      "vim.visualModeKeyBindings" = [];
    };
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
    keybindings = [
      {
        key = "ctrl+t";
        command = "-workbench.action.quickOpen";
      }
      {
        key = "ctrl+t";
        command = "cline.openInNewTab";
      }
    ];
  };
}
