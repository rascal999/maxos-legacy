{ config, lib, pkgs, ... }:

{
  # Firefox system-wide configuration
  environment.systemPackages = [ pkgs.firefox ];

  # System-wide policies
  environment.etc."firefox/policies/policies.json".source = ./policies.json;
}
