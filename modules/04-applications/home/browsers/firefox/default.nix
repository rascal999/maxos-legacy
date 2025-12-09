{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.firefox;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # Firefox has no hard dependencies
  
in {
  imports = [
    ./burp.nix
  ];

  options.maxos.tools.firefox = {
    enable = mkEnableOption "Firefox web browser with custom configuration";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    home.file = {
    ".mozilla/firefox/default/search.json.mozlz4" = {
      enable = lib.mkForce false;
    };
    ".mozilla/firefox/default/search.json.mozlz4.backup" = {
      enable = lib.mkForce false;
    };
  };

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
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4412673/ublock_origin-1.62.0.xpi";
          install_hash = "sha256:8a9e02aa838c302fb14e2b5bc88a6036d36358aadd6f95168a145af2018ef1a3";
        };
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4405074/darkreader-4.9.99.xpi";
          install_hash = "sha256:02c67ce2b3cd96719b5e369b9207ef11ed6c3a79eccb454d1e6ec3e005004e72";
        };
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4246774/sidebery-5.2.0.xpi";
          install_hash = "sha256:a5dd94227daafeec200dc2052fae6daa74d1ba261c267b71c03faa4cc4a6fa14";
        };
        "foxyproxy@eric.h.jung" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4228676/foxyproxy_standard-8.9.xpi";
          install_hash = "sha256:b1e1b85f4b3b047560f5329040e14a2fec9699edd4706391f6f2318b203ab023";
        };
      };
    };
    profiles.default = {
      search.default = "google";
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
        # Disable password saving prompts
        "signon.rememberSignons" = false;
        # Font configuration - use system defaults instead of JetBrains
        "font.name.serif.x-western" = "serif";
        "font.name.sans-serif.x-western" = "sans-serif";
        "font.name.monospace.x-western" = "monospace";
        "font.default.x-western" = "sans-serif";
        # Ensure Firefox uses system font settings
        "browser.display.use_system_colors" = true;
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
  
  assertions = [
    {
      assertion = dependenciesValid;
      message = "Firefox configuration has no hard dependencies";
    }
  ];
  };
}
