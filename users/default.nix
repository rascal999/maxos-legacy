# Import all user configurations in this directory
{ config, pkgs, lib, ... }:

let
  # Get all files in this directory
  files = builtins.readDir ./.;
  
  # Filter for .nix files that are not default.nix or in docs/
  userFiles = lib.filterAttrs (name: type:
    type == "regular" &&
    lib.hasSuffix ".nix" name &&
    name != "default.nix" &&
    !lib.hasPrefix "docs/" name
  ) files;
  
  # Convert filenames to paths
  userPaths = map (name: ./. + "/${name}") (builtins.attrNames userFiles);

in {
  # Import all user configurations
  imports = userPaths;
}
