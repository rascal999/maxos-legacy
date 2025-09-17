{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/01-core/system/user.nix
  ];

  # Use layered user configuration
  maxos.user = {
    enable = true;
    name = "user";
    homeDirectory = "/home/user";
    fullName = "MaxOS User";
    email = "user@example.com";
  };
  
  # System user configuration (additional settings)
  users.users.user = {
    initialPassword = "nixos";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "tty" "input" ];
  };
  
  # Display manager configuration (moved to system level)
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
  };
}
