# Main MaxOS modules file with layered architecture
# This follows recursion prevention guidelines by separating system and home modules
{ config, lib, pkgs, ... }:

{
  imports = [
    # Import layered system modules
    ./system-layered.nix
    
    # Import layered home-manager modules
    ./home-layered.nix
  ];
}