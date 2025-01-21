{ config, lib, pkgs, ... }:

let
  redshiftScript = pkgs.writeShellScriptBin "redshift-brightness" (builtins.readFile ../../desktop/redshift-brightness.sh);
in
{
  home.packages = with pkgs; [
    i3status-rust
    redshiftScript
  ];

  # Configure i3status-rust
  xdg.configFile."i3status-rust/config-default.toml".source = ./config-default.toml;
}
