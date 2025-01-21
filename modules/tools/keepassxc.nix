{ config, lib, pkgs, ... }:

{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Configure dark theme
  home-manager.users.user = {
    xdg.configFile."keepassxc/keepassxc.ini" = {
      text = ''
[General]
ConfigVersion=2

[GUI]
ApplicationTheme=dark
      '';
      force = true;
    };
  };
}
