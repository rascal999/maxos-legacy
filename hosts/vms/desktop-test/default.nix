{ config, pkgs, lib, ... }:

{
  imports = [
    ../../profiles/vm.nix             # VM-specific optimizations
    ../../profiles/desktop.nix        # Desktop profile to test
    ../../profiles/vm-hardware.nix    # Shared VM hardware config
  ];

  # VM-specific configuration
  networking = {
    hostName = "desktop-test-vm";
    useDHCP = true;  # Simplified networking for VM
  };

  # Override some desktop profile settings for VM
  services = {
    # Disable power management in VM
    thermald.enable = false;
    tlp.enable = false;
    
    # Enable SPICE agent for better integration
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
  };

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
  home-manager.users.user = { pkgs, ... }: {
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

  # System state version
  system.stateVersion = "23.11";
}
