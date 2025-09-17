{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.vscode;
  # In home-manager context, use home.homeDirectory
  userConfig = {
    homeDirectory = config.home.homeDirectory;
  };
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # VSCode has no hard dependencies
  
in {
  options.maxos.tools.vscode = {
    enable = mkEnableOption "Visual Studio Code editor";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    userSettings = {
      "workbench.startupEditor" = "none";
      "terminal.integrated.defaultProfile.linux" = "bash";
      "terminal.integrated.env.linux" = {
        "KUBECONFIG" = "${userConfig.homeDirectory}/.kube/config";
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
