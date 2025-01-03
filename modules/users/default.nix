{ config, lib, pkgs, ... }:

{
  users = {
    mutableUsers = false;
    users.user = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      hashedPassword = "$6$YdPBODxwZJXE$0DN3gn9DEHOHhqFH9iGzZvzQDqQyIoNGdAGseXgf4lCGhXDGkE/Ss7tZRPBBhJl0QVX7mRxnVxrdo0qhYLVBo/";  # "nixos"
      createHome = true;
      home = "/home/user";
      shell = pkgs.bash;
    };
  };

  security.sudo.wheelNeedsPassword = true;

  # Enable display manager for easier login
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };
}
