{ config, pkgs, lib, ... }:

{
  imports = [
    ../../profiles/vm.nix             # VM-specific optimizations and hardware config
    ../../profiles/desktop.nix        # Desktop profile to test
  ];

  # VM-specific configuration
  networking = {
    hostName = "desktop-test";   # Remove -vm suffix since qemu-vm.nix will add it
  };

  # Override some desktop profile settings for VM
  services = {
    # Disable power management in VM
    thermald.enable = lib.mkForce false;
    tlp.enable = lib.mkForce false;
  };

  # Disable hardware features not needed in VM
  hardware.bluetooth.enable = lib.mkForce false;

  # Ensure overlays are properly configured
  nixpkgs.overlays = [];

  # Additional packages for testing desktop features
  environment.systemPackages = with pkgs; [
    # Testing tools
    xorg.xev          # X event viewer
    xorg.xwininfo     # Window information utility
    glxinfo           # OpenGL information
    vulkan-tools      # Vulkan information
    
    # Demo applications
    libreoffice       # Office suite for testing
    gimp              # Image editor for testing
    firefox           # Web browser for testing
  ];

  # VM-specific home-manager configuration
  home-manager.users.${config.users.users.user.name} = { pkgs, ... }: {
    # Test user configuration
    home.packages = with pkgs; [
      # Development tools for testing
      vscode
      
      # Media applications
      vlc
      
      # Additional utilities
      flameshot       # Screenshot tool
      peek           # Screen recorder
    ];
  };

  # Set initial password for testing
  users.users.user.initialPassword = "nixos";

  # System state version
  system.stateVersion = "23.11";
}
