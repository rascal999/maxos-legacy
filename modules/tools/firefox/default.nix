{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    firefox
  ];

  # Firefox policies configuration
  home.file.".mozilla/firefox/policies/policies.json" = {
    source = ./policies.json;
  };
}
