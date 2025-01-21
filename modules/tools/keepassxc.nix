{ config, lib, pkgs, ... }:

{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];
}
