{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # Configure redshift for constant warm color temperature
  home-manager.users.user.services.redshift = {
    enable = true;
    provider = "manual";
    temperature = {
      day = 1900;
      night = 1900;
    };
    latitude = "51.5";  # London coordinates
    longitude = "-0.1";
    settings = {
      randr = {
        method = "vidmode";
      };
    };
  };


  # X server configuration
  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
  };
}
