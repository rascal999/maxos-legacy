{ config, lib, pkgs, ... }:

{
  imports = [
    ../tools/keepassxc.nix
  ];

  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # X server configuration
  services.xserver.enable = true;

  # Display manager configuration
  services.displayManager.autoLogin = {
    enable = true;
    user = "user";
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    awscli2
    bc  # For floating point calculations in brightness control
    electrum  # Bitcoin wallet
    gnupg  # For verifying Electrum binary
    jupyter
    maim
    micromamba
    pciutils  # Provides lspci command
    redshift  # For color temperature and brightness adjustment
    scrot
    uv
    xdotool
    xorg.xrandr
    pkgs.chromium
    pkgs.python3
    pkgs.xclip
    sqlmap  # SQL injection testing tool
    mitmproxy  # HTTP/HTTPS interception proxy
  ];

  # Enable dconf for GTK settings
  programs.dconf.enable = true;

  # Shell aliases
  environment.shellAliases = {
    "verify-electrum" = "/home/user/git/github/monorepo/maxos/scripts/verify-electrum";
  };
}
