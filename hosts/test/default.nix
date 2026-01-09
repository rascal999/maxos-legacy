{ config, pkgs, lib, ... }:

{
  imports = [
    # Import main system modules - handled by host-config.nix
  ];

  # Test user configuration
  maxos.user = {
    name = "user";
    homeDirectory = "/home/user";
  };

  # Enable secrets management for testing
  maxos.secrets = {
    enable = true;
    age.generateKey = true;
    defaultSopsFile = "${config.maxos.user.secretsDirectory}/hosts/test/secrets.yaml";
  };
  
  # Enable centralized font management
  maxos.fonts.enable = true;

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
  
  system.stateVersion = "25.11";
}