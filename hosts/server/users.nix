{ config, pkgs, ... }:

{
  # Define a user account
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here
    ];
    shell = pkgs.bash;
  };

  # Allow sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;
}