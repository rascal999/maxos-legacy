{ config, lib, pkgs, ... }:

{
  # Enable redshift systemd user service
  services.redshift = {
    enable = true;
    temperature = {
      day = 6500;
      night = 2000;
    };
    brightness = {
      day = "1.0";
      night = "0.8";
    };
    # Don't use the forced provider mode
    extraOptions = [ "-v" ];
  };
}
