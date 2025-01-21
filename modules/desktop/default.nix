{ config, lib, pkgs, ... }:

let
  redshiftBrightness = pkgs.writeShellScriptBin "redshift-brightness" (builtins.readFile ./redshift-brightness.sh);
in
{
  home.packages = with pkgs; [
    redshiftBrightness
  ];
}
