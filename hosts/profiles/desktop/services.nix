{ config, pkgs, lib, ... }:

{
  # Desktop services configuration
  services = {
    # Automounting
    udisks2.enable = true;
    gvfs.enable = true;
    
    # Printing
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplip ];
    };
    
    # DBus
    dbus.enable = true;
  };

  # Security configuration
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    
    # PAM
    pam = {
      services = {
        login.enableGnomeKeyring = true;
        swaylock = {};
      };
    };
  };

  # Docker configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
