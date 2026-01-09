{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.maxos.tools.steam;
in
{
  options.maxos.tools.steam = {
    enable = mkEnableOption "Steam";
  };

  config = mkIf cfg.enable {
    # Enable Steam
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open firewall for remote play
      dedicatedServer.openFirewall = true; # Open firewall for dedicated servers
    };

    # Add steam to system packages if not already handled by programs.steam
    # environment.systemPackages = with pkgs; [ steam ];

    # Might be necessary for some games or Steam itself
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    # Ensure 32-bit userspace libraries are available for Steam and many games
    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver # VAAPI driver for Intel GPUs
      intel-vaapi-driver # VAAPI driver for Intel GPUs (older)
      libva-vdpau-driver # VAAPI to VDPAU wrapper
      libvdpau-va-gl     # VDPAU driver with VA-API/OpenGL backend
    ];
    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
      # Add 32-bit equivalents if needed, e.g. libva-intel-driver
    ];

    # Add user to video group for hardware acceleration
    users.users.user.extraGroups = [ "video" ];

    # Fonts for Steam and games
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans # Corrected font name
      noto-fonts-color-emoji
      liberation_ttf
      corefonts # Microsoft TrueType core fonts
    ];

    # Networking - ensure necessary ports are open if not handled by programs.steam
    # networking.firewall.allowedTCPPorts = [ 27015 27036 ];
    # networking.firewall.allowedUDPPorts = [ 27015 27036 ];
  };
}