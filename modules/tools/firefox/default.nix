{ config, lib, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      DisableFirefoxAccounts = true;
      DisableProfileImport = true;
      NoDefaultBookmarks = true;
      DisplayMenuBar = "default-off";
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4143363/ublock_origin-1.55.0.xpi";
          install_hash = "sha256:45896a5f025ba29be041471a24675f9ca5817eecc37127d3c01190ca3a9f71e6";
        };
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4143302/darkreader-4.9.73.xpi";
          install_hash = "sha256:a01acf6d7914819651b6fbc40bb7226d1bf072b2f110e0f126ead61cf6d02873";
        };
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4142349/sidebery-5.0.0b32.xpi";
          install_hash = "sha256:9e080479ffbe93fdb56b25dca88ac1df31b1636e81f87f9eab12960842ca54c2";
        };
        "foxyproxy@eric.h.jung" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4124723/foxyproxy_standard-7.5.2.xpi";
          install_hash = "sha256:931d1e331fe047de3e8845495bf3fa59ed7f0d9ec1d3f09eace12a5d64349f53";
        };
        "keepassxc-browser@keepassxc.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4143359/keepassxc_browser-1.8.10.xpi";
          install_hash = "sha256:302edb6cd3a80faaf9266dee962f98625a3a46a7755fa85372aabcb1889732ac";
        };
      };
    };
    profiles.default = {
      search.default = "DuckDuckGo";
      isDefault = true;
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
