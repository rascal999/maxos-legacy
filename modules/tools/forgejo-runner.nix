{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.forgejo-runner;
in
{
  options.modules.tools.forgejo-runner = {
    enable = mkEnableOption "Forgejo Actions Runner";

    instances = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "this Forgejo runner instance";

          name = mkOption {
            type = types.str;
            description = "Name of the runner instance";
          };

          url = mkOption {
            type = types.str;
            description = "Forgejo instance URL";
            example = "https://code.forgejo.org/";
          };

          tokenFile = mkOption {
            type = types.path;
            description = "Path to file containing the registration token in format TOKEN=<secret>";
          };

          labels = mkOption {
            type = types.listOf types.str;
            default = [
              "docker:docker://node:20-bookworm"
              "ubuntu-latest:docker://node:20-bookworm"
            ];
            description = "Labels for the runner to determine which jobs it can run";
            example = [
              "node-22:docker://node:22-bookworm"
              "nixos-latest:docker://nixos/nix"
              "ubuntu-latest:docker://ubuntu:latest"
            ];
          };

          hostPackages = mkOption {
            type = types.listOf types.package;
            default = with pkgs; [ bash coreutils git ];
            description = "Packages available to the runner on the host";
          };

          settings = mkOption {
            type = types.attrs;
            default = {};
            description = "Additional configuration settings for the runner";
            example = {
              log.level = "info";
              runner.capacity = 1;
              cache.enabled = true;
              container.network = "";
              container.privileged = false;
              container.options = "";
              container.workdir_parent = "";
              container.valid_volumes = [];
              container.docker_host = "-";
              container.force_pull = false;
            };
          };
        };
      });
      default = {};
      description = "Forgejo runner instances";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.forgejo-runner;
      description = "The forgejo-runner package to use";
    };

    enableDocker = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Docker support for container-based jobs";
    };

    enableIPv6 = mkOption {
      type = types.bool;
      default = false;
      description = "Enable IPv6 support in Docker networks";
    };
  };

  config = mkIf cfg.enable {
    # Enable Docker if requested
    virtualisation.docker = mkIf cfg.enableDocker {
      enable = true;
      daemon.settings = mkIf cfg.enableIPv6 {
        ipv6 = true;
        fixed-cidr-v6 = "fd00::/80";
      };
    };

    # Configure firewall for Docker bridge interfaces if using cache actions
    networking.firewall.trustedInterfaces = mkIf cfg.enableDocker [ "br-+" ];

    # Use the NixOS gitea-actions-runner service for each instance
    services.gitea-actions-runner = {
      package = cfg.package;
      instances = mapAttrs (name: instanceCfg: {
        enable = instanceCfg.enable;
        name = instanceCfg.name;
        url = instanceCfg.url;
        tokenFile = instanceCfg.tokenFile;
        labels = instanceCfg.labels;
        hostPackages = instanceCfg.hostPackages;
        settings = {
          log = {
            level = "info";
            job_level = "info";
          };
          runner = {
            file = ".runner";
            capacity = 1;
            timeout = "3h";
            shutdown_timeout = "3h";
            insecure = false;
            fetch_timeout = "5s";
            fetch_interval = "2s";
            report_interval = "1s";
          };
          cache = {
            enabled = true;
            dir = "";
            host = "";
            port = 0;
            proxy_port = 0;
            external_server = "";
            secret = "";
            actions_cache_url_override = "";
          };
          container = {
            network = "";
            enable_ipv6 = cfg.enableIPv6;
            privileged = false;
            options = "";
            workdir_parent = "";
            valid_volumes = [];
            docker_host = "-";
            force_pull = false;
            force_rebuild = false;
          };
          host = {
            workdir_parent = "";
          };
        } // instanceCfg.settings;
      }) cfg.instances;
    };

    # Ensure runner users are properly configured
    users.users = mapAttrs' (name: instanceCfg:
      nameValuePair "gitea-runner-${name}" {
        isSystemUser = true;
        group = "gitea-runner-${name}";
        extraGroups = mkIf cfg.enableDocker [ "docker" ];
        home = "/var/lib/gitea-runner-${name}";
        createHome = true;
      }
    ) (filterAttrs (name: instanceCfg: instanceCfg.enable) cfg.instances);

    # Create corresponding groups for runner users
    users.groups = mapAttrs' (name: instanceCfg:
      nameValuePair "gitea-runner-${name}" {}
    ) (filterAttrs (name: instanceCfg: instanceCfg.enable) cfg.instances);

    # Add forgejo-runner package to system packages
    environment.systemPackages = [ cfg.package ];
  };
}