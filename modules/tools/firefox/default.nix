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
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4121906/ublock_origin-1.54.0.xpi";
          install_hash = "sha256:e1f36e2ad0e2c5d5c0c1a9c2c4e9bb7f0500a6ee51e8c3c1e93f3f4a3b6c310";
        };
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4121414/darkreader-4.9.70.xpi";
          install_hash = "sha256:d436c8663c5f9d2a71c7fd0fea8a7a3505c4f9ec1a5ce5aad9c45685e847c35d";
        };
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4123416/sidebery-5.0.0b31.xpi";
          install_hash = "sha256:0c1d50c50b0e0f4538d5e6056c0ce4d8e4e6f5f47f53be489d21e6e6d8f663d4";
        };
        "foxyproxy@eric.h.jung" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4051384/foxyproxy_standard-7.5.1.xpi";
          install_hash = "sha256:8f1d3f3c6f3af2aff7fdd67b5e9af2d699b23b7c73dc3e5e831dbed2b0a88b1e";
        };
        "keepassxc-browser@keepassxc.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4117666/keepassxc_browser-1.8.9.xpi";
          install_hash = "sha256:6b7d45e60d2a8a4f42d2a8cc8b581c8d8e6e7e874dc99e7e4e2c5ac3c81c6d2e";
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
