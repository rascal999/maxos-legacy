{ config, lib, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      DisableFirefoxAccounts = true;
      DisableProfileImport = true;
      NoDefaultBookmarks = true;
      DisplayMenuBar = "default-off";
    };
    extensions = with pkgs.firefox-addons; [
      ublock-origin
      darkreader
      sidebery
      foxyproxy-standard
      keepassxc-browser
    ];
    profiles.default = {
      settings = {
        # Enable dark theme
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        # Dark mode preferences
        "browser.in-content.dark-mode" = true;
        "ui.systemUsesDarkTheme" = 1;
        # Enable userChrome customizations
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Show bookmarks toolbar
        "browser.toolbars.bookmarks.visibility" = "always";
        # Always restore previous session
        "browser.startup.page" = 3;
        "browser.sessionstore.resume_from_crash" = true;
        "browser.sessionstore.max_tabs_undo" = 50;
        "browser.sessionstore.max_windows_undo" = 10;
      };
      userChrome = ''
        /* Pin DarkReader extension button */
        #wrapper-addon\@darkreader\.org,
        #addon\@darkreader\.org-browser-action {
          display: flex !important;
          -moz-box-ordinal-group: 0 !important;
        }

        /* Hide tab bar */
        #TabsToolbar {
          visibility: collapse !important;
        }
      '';
    };
  };
}
