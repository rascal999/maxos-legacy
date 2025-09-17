{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/01-core/system/user.nix
  ];

  # Use shared user configuration with additional groups
  maxos.sharedUser = {
    enable = true;
    username = "user";
    initialPassword = "nixos";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "tty" "input" ];
    enableDisplayManager = true;
    displayManager = "lightdm";
    desktopEnvironment = "i3";
  };
}
