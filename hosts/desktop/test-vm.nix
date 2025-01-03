{ config, pkgs, lib, ... }:

{
  # VM-specific settings
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096; # MB
      cores = 4;
      graphics = true;
      resolution = { x = 1920; y = 1080; };
    };
    boot = {
      consoleLogLevel = 7;
      kernelParams = [ "console=ttyS0" "boot.shell_on_fail" "loglevel=7" ];
    };
  };

  # VM-specific networking
  networking.hostName = "desktop-test-vm";
}
