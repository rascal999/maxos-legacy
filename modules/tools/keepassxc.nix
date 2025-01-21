{ config, lib, pkgs, ... }:

{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Configure KeePassXC using home-manager
  home-manager.users.user = {
    xdg.configFile."keepassxc/keepassxc.ini" = {
      text = ''
[Browser]
Enabled=true
AlwaysAllowAccess=true
CustomProxyLocation=
Chromium\Enabled=true
Chromium\CustomProxyLocation=
Firefox\Enabled=true
Firefox\CustomProxyLocation=

[GUI]
ApplicationTheme=dark
ShowTrayIcon=true
TrayIconAppearance=monochrome-light

[General]
ConfigVersion=2
ShowToolbar=true
MinimizeAfterUnlock=false

[Security]
ClearClipboardTimeout=30
LockDatabaseIdle=true
LockDatabaseIdleSeconds=600

[KeeShare]
Own=""

[PasswordGenerator]
AdditionalChars=
ExcludedChars=
      '';
      force = true;
    };

    # Enable native messaging for browser integration
    xdg.configFile."mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" = {
      text = ''
{
    "allowed_extensions": [
        "keepassxc-browser@keepassxc.org"
    ],
    "description": "KeePassXC integration with native messaging support",
    "name": "org.keepassxc.keepassxc_browser",
    "path": "${pkgs.keepassxc}/bin/keepassxc-proxy",
    "type": "stdio"
}
      '';
      force = true;
    };
  };

  # Ensure native messaging directory exists with correct permissions
  systemd.user.tmpfiles.rules = [
    "d %h/.mozilla/native-messaging-hosts 0755 user users - -"
  ];
}
