{ config, lib, pkgs, ... }:

{
  home.file = {
    ".mozilla/firefox/burp/search.json.mozlz4" = {
      enable = lib.mkForce false;
    };
    ".mozilla/firefox/burp/search.json.mozlz4.backup" = {
      enable = lib.mkForce false;
    };
  };

  programs.firefox = {
    enable = true;
    profiles.burp = {
      id = 1;
      isDefault = false;
      search.default = "google";
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
        # Disable password saving prompts
        "signon.rememberSignons" = false;
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