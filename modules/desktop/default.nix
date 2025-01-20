{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # Add user to video group for screen color temperature control
  users.users.user.extraGroups = [ "video" ];

  # Configure sct for constant warm color temperature
  systemd.services.sct = {
    description = "Set color temperature using sct";
    wantedBy = [ "multi-user.target" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "user";
      Group = "video";
      ExecStart = "${pkgs.sct}/bin/sct 1900";
      ExecStop = "${pkgs.sct}/bin/sct";
      Environment = "DISPLAY=:0 XAUTHORITY=/home/user/.Xauthority";
    };
  };

  # X server configuration
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager = {
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
  };

  # Enable NVIDIA driver and tools
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = true;  # Required for driver versions >= 560
  };

  environment.systemPackages = with pkgs; [
    sct
    xorg.xrandr
    config.boot.kernelPackages.nvidia_x11
  ];
}
