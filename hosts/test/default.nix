{ config, pkgs, lib, ... }:

{
  imports = [
    # Test basic imports
    ../../modules/core/user.nix
    ../../modules/core/secrets.nix
  ];

  # Test user configuration
  maxos.user = {
    name = "user";
    homeDirectory = "/home/user";
  };

  # Test secrets (disabled for now)
  maxos.secrets.enable = false;

  # Test individual tools that we know work
  modules.tools = {
    docker.enable = true;
    chromium.enable = true;
    keepassxc.enable = true;
  };

  # Basic filesystem configuration for testing
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/test-root";
    fsType = "ext4";
  };
  
  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "test";
  networking.networkmanager.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  system.stateVersion = "25.05";
}