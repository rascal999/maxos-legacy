{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # X server configuration
  services.xserver = {
    displayManager = {
      sessionCommands = ''
        # Enable Firefox touchpad gestures
        export MOZ_USE_XINPUT2=1
      '';
    };
  };
}
