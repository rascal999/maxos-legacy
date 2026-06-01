{ config, lib, pkgs, ... }:

{
  options.maxos.tools.npm = {
    enable = lib.mkEnableOption "npm";
  };

  config = lib.mkIf config.maxos.tools.npm.enable {
    environment.systemPackages = with pkgs; [
      nodejs
      esbuild  # Add esbuild JavaScript bundler
    ];
  };
}