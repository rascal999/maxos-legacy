{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/desktop.nix          # Common desktop configuration
    ./hardware-configuration.nix      # Machine-specific hardware config
    ./display.nix                     # Display and window manager configuration
    ./audio.nix                       # Audio configuration
    ./networking.nix                  # Network configuration
  ];

  # Machine-specific configuration
  networking.hostName = "hero";

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # For better hardware support
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];  # Adjust for AMD if needed
  };

  # Hardware-specific configuration
  hardware.cpu.intel.updateMicrocode = true;  # Change to cpu.amd for AMD

  # Additional packages specific to this machine
  environment.systemPackages = with pkgs; [
    # Additional browsers
    chromium
    
    # Additional media
    spotify
    
    # Additional development tools
    postman
    
    # Additional graphics
    inkscape
  ];

  # Machine-specific home-manager configuration
  home-manager.users.user = { pkgs, ... }: {
    imports = [
      ../../home/profiles/desktop.nix
    ];

    # Additional user packages specific to this machine
    home.packages = with pkgs; [
      zoom-us
    ];
  };

  # System state version
  system.stateVersion = "23.11";
}
