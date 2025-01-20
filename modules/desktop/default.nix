{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # Configure gammastep for constant warm color temperature
  home-manager.users.user.programs.gammastep = {
    enable = true;
    settings = {
      general = {
        temp-day = 1900;
        temp-night = 1900;
        dawn-time = "0:00";
        dusk-time = "0:00";
      };
    };
  };


  # X server configuration
  services.xserver = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "user";
      };
      sessionCommands = ''
        # Enable Firefox touchpad gestures
        export MOZ_USE_XINPUT2=1
      '';
    };
  };
}
