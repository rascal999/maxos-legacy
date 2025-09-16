{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/core/shared-user.nix
  ];

  # Use shared user configuration
  maxos.sharedUser = {
    enable = true;
    username = "user";
    initialPassword = "nixos";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
    enableDisplayManager = true;
    displayManager = "lightdm";
    desktopEnvironment = "xfce";
  };
}
