{ config, lib, pkgs, ... }:

let
  setupScript = pkgs.writeScriptBin "setup-keepassxc" ''
    #!${pkgs.bash}/bin/bash
    CONFIG_DIR="$HOME/.config/keepassxc"
    CONFIG_FILE="$CONFIG_DIR/keepassxc.ini"
    NATIVE_MSG_DIR="$HOME/.mozilla/native-messaging-hosts"
    
    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$NATIVE_MSG_DIR"
    
    # Create config file if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ] || [ ! -w "$CONFIG_FILE" ]; then
      cat > "$CONFIG_FILE" << EOL
[Browser]
Enabled=true
AlwaysAllowAccess=true
CustomProxyLocation=
Chromium\\Enabled=true
Chromium\\CustomProxyLocation=
Firefox\\Enabled=true
Firefox\\CustomProxyLocation=

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
EOL
    fi
    
    # Set proper permissions
    chmod 600 "$CONFIG_FILE"
    chown $USER:users "$CONFIG_FILE"
    
    # Setup native messaging for Firefox
    cat > "$NATIVE_MSG_DIR/org.keepassxc.keepassxc_browser.json" << EOL
{
    "allowed_extensions": [
        "keepassxc-browser@keepassxc.org"
    ],
    "description": "KeePassXC integration with native messaging support",
    "name": "org.keepassxc.keepassxc_browser",
    "path": "${pkgs.keepassxc}/bin/keepassxc-proxy",
    "type": "stdio"
}
EOL
    
    chmod 755 "$NATIVE_MSG_DIR"
    chmod 644 "$NATIVE_MSG_DIR/org.keepassxc.keepassxc_browser.json"
  '';
in
{
  # Install KeePassXC and setup script
  environment.systemPackages = with pkgs; [
    keepassxc
    setupScript
  ];

  # Create systemd user service to run setup on login
  systemd.user.services.keepassxc-setup = {
    description = "Setup KeePassXC configuration";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${setupScript}/bin/setup-keepassxc";
      RemainAfterExit = true;
    };
  };
}
