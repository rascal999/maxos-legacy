{ config, lib, pkgs, ... }:

{
  imports = [
    ./redshift.nix
  ];

  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # X server configuration
  services.xserver = {
    enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };
  };

  environment.systemPackages = with pkgs; [
    xorg.xrandr
    pciutils  # Provides lspci command
    bc  # For floating point calculations in brightness control
  ];

  # Install brightness control script
  system.activationScripts.brightness = ''
    mkdir -p /etc/nixos/brightness
    cp ${./brightness.sh} /etc/nixos/brightness/brightness.sh
    chmod +x /etc/nixos/brightness/brightness.sh
  '';
}
