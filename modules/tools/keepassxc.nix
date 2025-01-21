{ config, lib, pkgs, ... }:

{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Configure dark theme using home-manager
  home-manager.users.user.home.file = {
    ".config/keepassxc/keepassxc.ini".text = ''
[General]
ConfigVersion=2

[GUI]
ApplicationTheme=dark
    '';
  };
}
