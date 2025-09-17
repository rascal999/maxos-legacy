{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/01-core/system/user.nix
  ];

  # Use shared user configuration
  maxos.sharedUser = {
    enable = true;
    username = "user";
    initialPassword = "password";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" ];
    enableDisplayManager = true;
    displayManager = "lightdm";
    desktopEnvironment = "xfce";
  };
}
