{ config, pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    ./users.nix
  ];

  # Basic system configuration shared across all hosts
  boot.cleanTmpDir = true;
  
  # System-wide packages
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    htop
  ];

  # Basic networking configuration
  networking = {
    useDHCP = false;
    firewall.enable = true;
  };

  # Basic security settings
  security = {
    sudo.enable = true;
    # Enable PAM
    pam.enableSSHAgentAuth = true;
  };

  # System-wide SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Default locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Time zone
  time.timeZone = "UTC";

  # System features
  system.stateVersion = "23.11"; # Set appropriate version

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
