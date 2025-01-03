{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ./home.nix
  ];
}
