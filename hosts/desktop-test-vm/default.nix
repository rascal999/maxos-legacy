{ config, pkgs, lib, ... }:

{
  imports = [
    ../desktop
  ];

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096; # MB
      cores = 2;
      graphics = true;
    };
  };
}
