{ config, pkgs, lib, ... }:

{
  imports = [
    ../../profiles/vm.nix             # VM-specific optimizations and hardware config
    ../../profiles/server.nix         # Server profile to test
  ];

  # VM-specific configuration
  networking = {
    hostName = "server-test";  # Remove -vm suffix since qemu-vm.nix will add it
    useDHCP = lib.mkForce true;  # Simplified networking for VM
  };

  # Test services
  services = {
    # Example web server for testing
    nginx = {
      enable = true;
      virtualHosts."localhost" = {
        locations."/" = {
          return = "200 'Server profile test VM running'";
        };
      };
    };
  };

  # Additional packages for testing
  environment.systemPackages = with pkgs; [
    # Testing tools
    apacheHttpd # Provides ab (apache bench)
    siege
    wrk
  ];

  # System state version
  system.stateVersion = "23.11";
}
