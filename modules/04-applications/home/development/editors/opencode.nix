{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.opencode;

  dependenciesValid =
    config.maxos.user.enable or true;

in {
  options.maxos.tools.opencode = {
    enable = mkEnableOption "opencode configuration and user files";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # We deploy a clean template file. The opencode wrapper script will dynamically
    # populate the active opencode.jsonc with credentials at launch.
    home.file.".config/opencode/opencode.template.jsonc".text = ''
      {
        "$schema": "https://opencode.ai/config.json",
        "agent": {
          "Plan": {
            "model": "openrouter/google/gemini-3.5-flash"
          },
          "Build": {
            "model": "openrouter/google/gemini-3.5-flash"
          },
          "plan": {
            "model": "openrouter/google/gemini-3.5-flash"
          },
          "build": {
            "model": "openrouter/google/gemini-3.5-flash"
          }
        },
        "skills": {
          "paths": [
            "${config.home.homeDirectory}/git/github/monorepo/skills"
          ]
        },
        "mcp": {
          "context7": {
            "type": "remote",
            "url": "https://mcp.context7.com/mcp",
            "headers": {
              "Authorization": "@CONTEXT7_AUTHORIZATION@"
            },
            "enabled": true
          },
          "linear": {
            "type": "local",
            "command": [
              "npx",
              "-y",
              "mcp-server-linear"
            ],
            "enabled": true
          }
        },
        "permission": {
          "linear_*": "allow"
        }
      }
    '';

    home.file.".config/opencode/tui.json".text = ''
      {
        "$schema": "https://opencode.ai/tui.json",
        "keybinds": {
          "session_child_cycle": "tab",
          "session_child_cycle_reverse": "shift+tab",
          "agent_cycle": "none",
          "agent_cycle_reverse": "none"
        }
      }
    '';

    systemd.user.services.opencode-web = {
      Unit = {
        Description = "OpenCode Web Server Daemon";
        After = [ "gnome-keyring.service" "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/run/current-system/sw/bin/opencode serve --port 9000";
        Restart = "always";
        RestartSec = "10s";
        Environment = "PATH=${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin:/usr/bin:/bin";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
