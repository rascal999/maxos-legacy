{ config, lib, pkgs, ... }:

{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Create KeePassXC config directory and default config
  system.activationScripts.keepassxcConfig = {
    text = ''
      CONFIG_DIR="$HOME/.config/keepassxc"
      CONFIG_FILE="$CONFIG_DIR/keepassxc.ini"
      
      mkdir -p "$CONFIG_DIR"
      
      if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOL
[Browser]
Enabled=true
AlwaysAllowAccess=true

[General]
ConfigVersion=2
ShowToolbar=true
MinimizeAfterUnlock=false

[Security]
ClearClipboardTimeout=30
LockDatabaseIdle=true
LockDatabaseIdleSeconds=600
EOL
      fi
    '';
    deps = [];
  };
}
