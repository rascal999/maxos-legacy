{ config, lib, pkgs, ... }:

{
  # Configure KeePassXC through home-manager
  home-manager.users.user = {
    programs.keepassxc = {
      enable = true;
      settings = {
        GUI = {
          ApplicationTheme = "dark";
        };
      };
    };
  };
}
