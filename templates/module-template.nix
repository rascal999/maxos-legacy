# Standard NixOS Module Template for MaxOS
# This template provides the standardized structure for all MaxOS tool modules
#
# Usage: Copy this template and replace placeholders with actual values
# Placeholders to replace:
# - <TOOL_NAME>: The name of the tool (e.g., "docker", "npm")
# - <DESCRIPTION>: Brief description of the tool
# - <PACKAGE_LIST>: List of packages to install
# - <SERVICE_CONFIG>: Optional service configuration
# - <HOME_CONFIG>: Optional home-manager configuration

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.<TOOL_NAME>;
in {
  options.modules.tools.<TOOL_NAME> = {
    enable = mkEnableOption "<DESCRIPTION>";
    
    # Add tool-specific options here
    # Example options:
    # configFile = mkOption {
    #   type = types.str;
    #   default = "";
    #   description = "Path to configuration file";
    # };
    #
    # extraPackages = mkOption {
    #   type = types.listOf types.package;
    #   default = [];
    #   description = "Additional packages to install";
    # };
  };

  config = mkIf cfg.enable {
    # System packages
    environment.systemPackages = with pkgs; [
      <PACKAGE_LIST>
    ] ++ cfg.extraPackages or [];

    # System configuration (services, etc.)
    <SERVICE_CONFIG>

    # Home-manager configuration (if applicable)
    # home-manager.users.${config.maxos.user.name} = {
    #   <HOME_CONFIG>
    # };

    # Additional system configuration
    # networking.firewall.allowedTCPPorts = [ ... ];
    # systemd.services.<TOOL_NAME> = { ... };
    # etc.
  };
}