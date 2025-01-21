{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    i3status-rust
  ];

  # Configure i3status-rust
  xdg.configFile."i3status-rust/config-default.toml".source = ./config-default.toml;
}
