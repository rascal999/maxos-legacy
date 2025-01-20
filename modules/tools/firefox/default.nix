{ config, lib, pkgs, ... }:

{
  # Configure Firefox through home-manager
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
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

  # Environment variables for Firefox
  home.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";  # Enable touchpad gestures
  };
}
