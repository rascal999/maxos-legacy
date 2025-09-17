{ config, pkgs, ... }:

{
  imports = [
    ../../modules/01-core/system/user.nix
  ];

  # Use shared user configuration for server
  maxos.sharedUser = {
    enable = true;
    username = "user";
    initialPassword = "changeme";
    shell = pkgs.bash;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    enableDisplayManager = false; # Server doesn't need display manager
  };

  # Server-specific configuration
  users.users.user.openssh.authorizedKeys.keys = [
    # Add your SSH public keys here
  ];

  # Allow sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;
}