{ config, lib, pkgs, ... }:

{
  # Enable KeePassXC with browser integration
  programs.keepassxc = {
    enable = true;
    package = pkgs.keepassxc;
    settings = {
      General = {
        ConfigVersion = 2;
        ShowToolbar = true;
        MinimizeAfterUnlock = false;
      };
      Browser = {
        Enabled = true;
        AlwaysAllowAccess = true;
        CustomProxyLocation = "";
      };
      Security = {
        ClearClipboardTimeout = 30;
        LockDatabaseIdle = true;
        LockDatabaseIdleSeconds = 600;
      };
    };
  };

  # Firefox configuration for KeePassXC
  programs.firefox = {
    policies = {
      ExtensionSettings = {
        "keepassxc-browser@keepassxc.org" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
        };
      };
    };
  };
}
