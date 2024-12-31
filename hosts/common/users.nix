{ config, pkgs, lib, ... }:

{
  # Don't allow mutation of users outside of Nix configuration.
  users.mutableUsers = false;

  # Default shell for all users
  users.defaultUserShell = pkgs.zsh;

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxYneUbKLM8Bw/+WIqXplOtOoOmnGmWh9lg/7wliAUn user@rig"
    ];
  };
}
