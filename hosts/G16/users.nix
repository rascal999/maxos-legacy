{ config, lib, pkgs, ... }:

{
  users = {
    mutableUsers = true;
    users.user = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
      initialPassword = "nixos";
      createHome = true;
      home = "/home/user";
      shell = pkgs.zsh;
    };
  };

  # Enable display manager for easier login
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };
}
