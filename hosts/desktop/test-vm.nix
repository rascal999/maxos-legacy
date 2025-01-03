{ config, pkgs, lib, ... }:

{
  imports = [
    ./home.nix  # Import desktop home configuration
  ];

  # VM-specific settings
  virtualisation = {
    memorySize = 4096; # MB
    cores = 4;
    graphics = true;
    resolution = { x = 1920; y = 1080; };
    # Store VM-related files in tmp directory
    writableStore = "tmp/nix-store";
    writableStoreUseTmpfs = false;
  };

  # Create a test user
  users.users.testuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "testpass";
  };

  # VM-specific networking
  networking.hostName = "desktop-test-vm";
}
