{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    userSettings = {
      "workbench.startupEditor" = "none";
      "terminal.integrated.defaultProfile.linux" = "bash";
      "keyboard.dispatch" = "keyCode";
      "vim.useSystemClipboard" = true;
      "editor.lineNumbers" = "relative";
      "vim.hlsearch" = true;
      "vim.insertModeKeyBindings" = [];
      "vim.normalModeKeyBindings" = [];
      "vim.visualModeKeyBindings" = [];
      "settingsSync.ignoredSettings" = [];
      "settingsSync.ignoredExtensions" = [];
      "settingsSync.ignoredKeyBindings" = [];
      "settingsSync.keybindingsPerPlatform" = false;
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
        command = "roo-cline.openInNewTab";
      }
      {
        key = "ctrl+shift+t";
        command = "-workbench.action.reopenClosedEditor";
      }
      {
        key = "ctrl+shift+t";
        command = "cline.openInNewTab";
      }
    ];
  };
}
