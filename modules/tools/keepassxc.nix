{ config, lib, pkgs, ... }:

{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Create KeePassXC config with dark theme
  system.activationScripts.keepassxcConfig = {
    text = ''
      CONFIG_DIR="/home/user/.config/keepassxc"
      CONFIG_FILE="$CONFIG_DIR/keepassxc.ini"
      
      mkdir -p "$CONFIG_DIR"
      
      echo '[General]
ConfigVersion=2

[GUI]
ApplicationTheme=dark' > "$CONFIG_FILE"
      
      chown -R user:users "$CONFIG_DIR"
      chmod 644 "$CONFIG_FILE"
    '';
    deps = [];
  };
}
