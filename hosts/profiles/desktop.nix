{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/default.nix
    ./desktop/i3.nix
    ./desktop/hardware.nix
    ./desktop/services.nix
    ./desktop/packages.nix
  ];
}
