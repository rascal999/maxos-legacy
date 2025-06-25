{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.blocky;
in
{
  options.modules.tools.blocky = {
    enable = mkEnableOption "Blocky DNS";
  };

  config = mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
        upstreams = {
          groups = {
            default = [
              "8.8.8.8"
            ];
          };
        };
        blocking = {
          denylists = {
            ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
          };
          clientGroupsBlock = {
            default = [ "ads" ];
          };
        };
        customDNS = {
          mapping = {
            "moneyapi-api-testingeu.wl.preprod.mangopay.ninja" = "100.64.0.3";
          };
        };
        conditional = {
          mapping = {
            "test" = "127.0.0.1";
          };
        };
      };
    };
    # Ensure Blocky starts after the network is online
    systemd.services.blocky.after = [ "network-online.target" ];

    # Configure DNS resolution to point to Blocky
    networking.nameservers = [ "127.0.0.1" ];
    # Disable systemd-resolved to avoid conflicts with Blocky
    services.resolved.enable = false;
  };
}