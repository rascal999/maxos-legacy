{ config, lib, pkgs, ... }:

{
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

  # Remove Firefox from system packages since it's managed by home-manager
  home.packages = lib.mkAfter (with pkgs; [
    # Remove Firefox if it exists in the list
    # This is done using a filter function
    (lib.lists.filter (p: p.name != "firefox") config.home.packages)
  ]);
}
