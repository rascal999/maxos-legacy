# Main MaxOS modules file that imports all tool modules and tool bundles
# This includes both system-level and home-manager modules
{ config, lib, pkgs, ... }:

{
  imports = [
    # Import all system modules
    ./system.nix
    
    # Import all home-manager modules
    ./home.nix
  ];
}