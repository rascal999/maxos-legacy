{ config, pkgs, lib, ... }:

{
  imports = [
    ../../profiles/vm.nix             # VM-specific optimizations
    ../../profiles/server.nix         # Server profile to test
    ../../profiles/vm-hardware.nix    # Shared VM hardware config
  ];

  # VM-specific configuration
  networking = {
    hostName = "server-test-vm";
    useDHCP = true;  # Simplified networking for VM
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
    apache-bench
    siege
    wrk
  ];

  # System state version
  system.stateVersion = "23.11";
}
