{ config, pkgs, lib, ... }:

{
  imports = [
    ../desktop
  ];

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192; # MB
      cores = 2;
      graphics = true;
    };
  };
}
