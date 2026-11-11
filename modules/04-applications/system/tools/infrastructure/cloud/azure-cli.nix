# Azure CLI module
#
# Provides the Azure CLI (`az`) for managing Azure resources.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.azure-cli;
in {
  options.maxos.tools.azure-cli = {
    enable = mkEnableOption "Azure CLI (az)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      azure-cli
    ];
  };
}
