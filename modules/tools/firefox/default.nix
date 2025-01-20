{ config, lib, pkgs, ... }:

{
  # Configure Firefox through home-manager
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default";
      settings = {
        # Enable dark theme
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        # Dark mode preferences
        "browser.in-content.dark-mode" = true;
        "ui.systemUsesDarkTheme" = 1;
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        ublock-origin
      ];
    };
  };
}
