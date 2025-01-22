{ config, pkgs, lib, ... }:

let
  maxosScript = pkgs.writeShellScriptBin "maxos" (builtins.readFile ../../scripts/maxos);
  redshiftBrightness = pkgs.writeShellScriptBin "redshift-brightness" (builtins.readFile ../../scripts/redshift-brightness);
  clearUrgent = pkgs.writeShellScriptBin "clear-urgent" (builtins.readFile ../../scripts/clear-urgent);
in
{
  config = {
    environment.systemPackages = [
      maxosScript
      redshiftBrightness
      clearUrgent
      # Dependencies for redshift-brightness
      pkgs.bc  # For floating point calculations
      pkgs.jq  # For JSON output in get command
      pkgs.redshift  # For color temperature and brightness adjustment
    ];
  };
}
