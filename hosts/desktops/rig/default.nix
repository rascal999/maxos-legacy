{ config, pkgs, lib, ... }:

{
  imports = [
    ../../profiles/desktop.nix          # Common desktop configuration
    ./hardware-configuration.nix        # Machine-specific hardware config
  ];

  # Machine-specific configuration
  networking.hostName = "rig";

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # For better hardware support
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-amd" ];  # AMD CPU
  };

  # Hardware-specific configuration
  hardware.cpu.amd.updateMicrocode = true;

  # Additional packages specific to this machine
  environment.systemPackages = with pkgs; [
    # Development tools
    docker-compose
    kubernetes
    minikube
    
    # Content creation
    obs-studio
    kdenlive
    blender
    
    # Gaming
    steam
    lutris
    wine
    winetricks
    
    # Communication
    discord
    slack
    zoom-us
  ];

  # Enable Docker
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  # Machine-specific home-manager configuration
  home-manager.users.user = { pkgs, ... }: {
    imports = [
      ../../home/profiles/desktop.nix
    ];

    # Additional user packages specific to this machine
    home.packages = with pkgs; [
      # Development
      jetbrains.idea-ultimate
      android-studio
      
      # Gaming utilities
      gamemode
      mangohud
      
      # Media
      spotify
      vlc
    ];
  };

  # System state version
  system.stateVersion = "23.11";
}
