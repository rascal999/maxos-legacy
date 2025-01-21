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
    profiles.default = {
      search.default = "DuckDuckGo";
      extensions = [
        (pkgs.fetchFirefoxAddon {
          name = "ublock-origin";
          url = "https://addons.mozilla.org/firefox/downloads/file/4198829/ublock_origin-1.54.0.xpi";
          hash = "sha256-vHvHJR3yR1K2zYc5LnQGc4wXZwELHX9kGIELHEWQtYY=";
        })
        (pkgs.fetchFirefoxAddon {
          name = "darkreader";
          url = "https://addons.mozilla.org/firefox/downloads/file/4171050/darkreader-4.9.73.xpi";
          hash = "sha256-/TMvzFz7ucdqHKNl2P5VEVqXOHG3zvBhzXVOyU4t4Lg=";
        })
        (pkgs.fetchFirefoxAddon {
          name = "sidebery";
          url = "https://addons.mozilla.org/firefox/downloads/file/4183821/sidebery-5.0.0b37.xpi";
          hash = "sha256-Ql0fHBGkNZXNRKQrVFB6Cg9+9Yx/Qz4vLCPGCZHvKE=";
        })
        (pkgs.fetchFirefoxAddon {
          name = "foxyproxy-standard";
          url = "https://addons.mozilla.org/firefox/downloads/file/4186006/foxyproxy_standard-7.5.1.xpi";
          hash = "sha256-Qc9B6vN5v4A8c0MXnJ+LhKi3gMOwqUGMvL+QjPg0JXA=";
        })
        (pkgs.fetchFirefoxAddon {
          name = "keepassxc-browser";
          url = "https://addons.mozilla.org/firefox/downloads/file/4201213/keepassxc_browser-1.8.9.xpi";
          hash = "sha256-/KX8qOOZqxZQh/9R3IQ/vd1ntyqHHy0Y3Nq1eRdJHZE=";
        })
      ];
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
