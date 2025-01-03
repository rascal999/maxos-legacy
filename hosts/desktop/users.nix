{ config, lib, pkgs, ... }:

{
  users = {
    mutableUsers = true;
    defaultUserShell = pkgs.bash;
    users.user = {
      isNormalUser = true;
      description = "Default User";
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      initialPassword = "nixos";
      createHome = true;
      home = "/home/user";
    };
  };

  # Enable display manager for easier login
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };
}
