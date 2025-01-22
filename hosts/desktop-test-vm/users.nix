{ config, pkgs, ... }:

{
  # Define user account
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "password";
    shell = pkgs.zsh;
  };

  # Allow sudo without password for testing
  security.sudo.wheelNeedsPassword = false;
}
