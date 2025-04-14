{ config, lib, pkgs, ... }:

{
  options.modules.tools.npm = {
    enable = lib.mkEnableOption "npm";
  };

  config = lib.mkIf config.modules.tools.npm.enable {
    environment.systemPackages = with pkgs; [
      nodejs
      nodePackages.npm
      esbuild  # Add esbuild JavaScript bundler
    ];
  };
}