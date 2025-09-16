{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.vscode;
in {
  options.modules.tools.vscode = {
    enable = mkEnableOption "Visual Studio Code editor";
    
    homeDirectory = mkOption {
      type = types.str;
      default = "/home/user";
      description = "User's home directory path";
    };
  };

  config = mkIf cfg.enable {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    userSettings = {
      "workbench.startupEditor" = "none";
      "terminal.integrated.defaultProfile.linux" = "bash";
      "terminal.integrated.env.linux" = {
        "KUBECONFIG" = "${cfg.homeDirectory}/.kube/config";
      };
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
        command = "kilo-code.openInNewTab";
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
  };
}
