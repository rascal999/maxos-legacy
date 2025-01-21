{ config, lib, pkgs, ... }:

{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Configure dark theme
  home-manager.users.user = {
    xdg.configFile."keepassxc/keepassxc.ini".text = ''
[GUI]
ApplicationTheme=dark
    '';
  };
}
