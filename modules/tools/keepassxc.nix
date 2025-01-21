{ config, lib, pkgs, ... }:

{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Configure KeePassXC using home-manager
  home-manager.users.user = {
    home.file.".config/keepassxc/keepassxc.ini".text = ''
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
  };
}
