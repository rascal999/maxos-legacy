{ config, lib, pkgs, ... }:

{
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "nixos";
  };
}
