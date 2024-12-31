{ config, pkgs, lib, ... }:

{
  imports = [ ../../modules/ssh-keys.nix ];

  # Don't allow mutation of users outside of Nix configuration.
  users.mutableUsers = false;

  # Default shell for all users
  users.defaultUserShell = pkgs.zsh;

  # Enable SSH key management
  sshKeys = {
    enable = true;
    users = [ "root" "user" ]; # Add other users as needed
  };
}
