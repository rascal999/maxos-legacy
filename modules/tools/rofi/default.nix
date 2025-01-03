{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    rofi
    sqlite
    jq
  ];

  # Ensure rofi data directory exists
  home.file.".local/share/rofi/.keep".text = "";

  # Copy the rofi database
  home.file.".local/share/rofi/rofi.db" = {
    source = ./rofi.db;
  };

  # Install the launcher script
  home.file.".local/bin/rofi-launcher" = {
    source = ./launcher.sh;
    executable = true;
  };
}
