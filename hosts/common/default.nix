{ config, pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    ./users.nix
    ../../users/default.nix  # Import all user configurations
  ];

  # Enable zsh since it's used as the default shell
  programs.zsh.enable = true;

  # Basic system configuration shared across all hosts
  boot = {
    tmp.cleanOnBoot = true;
    readOnlyNixStore = true;
  };
  
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
    pam.sshAgentAuth.enable = true;
  };

  # Disable unnecessary services
  disabledModules = [
    "services/security/hologram-agent.nix"
    "services/networking/tayga.nix"
  ];

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

  # Basic program configurations
  programs.ccache = {
    enable = lib.mkForce false;  # Explicitly disable ccache system-wide
    packageNames = lib.mkForce [];  # Ensure packageNames is set even when disabled
  };
}
