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
            "${config.home.homeDirectory}/git/github/synlace/monorepo/skills"
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
          },
          "gmail": {
            "type": "local",
            "command": [
              "node",
              "${config.home.homeDirectory}/git/github/synlace/monorepo/tools/gmail-local-mcp.js"
            ],
            "enabled": true
          },
          "calendar": {
            "type": "local",
            "command": [
              "node",
              "${config.home.homeDirectory}/git/github/synlace/monorepo/tools/calendar-local-mcp.js"
            ],
            "enabled": true
          },
          "drive": {
            "type": "local",
            "command": [
              "node",
              "${config.home.homeDirectory}/git/github/synlace/monorepo/tools/drive-local-mcp.js"
            ],
            "enabled": true
          },
          "people": {
            "type": "local",
            "command": [
              "node",
              "${config.home.homeDirectory}/git/github/synlace/monorepo/tools/people-local-mcp.js"
            ],
            "enabled": true
          },
          "maps": {
            "type": "remote",
            "url": "https://mapstools.googleapis.com/mcp",
            "headers": {
              "X-Goog-Api-Key": "@GOOGLE_MAPS_API_KEY@"
            },
            "enabled": true
          }
        },
        "plugin": [
          "./maps-fix-plugin.ts"
        ],
        "permission": {
          "linear_*": "allow",
          "gmail_*": "allow",
          "calendar_*": "allow",
          "drive_*": "allow",
          "people_*": "allow",
          "maps_*": "allow"
        }
      }
    '';

    home.file.".config/opencode/maps-fix-plugin.ts".text = ''
      import type { Plugin } from "@opencode-ai/plugin";

      export default (async () => {
        return {
          "tool.definition": async (input, output) => {
            if (input.toolID === "maps_compute_routes") {
              if (output.parameters && output.parameters.properties) {
                const waypointSchema = {
                  anyOf: [
                    { type: "string" },
                    {
                      type: "object",
                      properties: {
                        address: { type: "string" },
                        placeId: { type: "string" },
                        place_id: { type: "string" },
                        location: {
                          type: "object",
                          properties: {
                            latLng: {
                              type: "object",
                              properties: {
                                latitude: { type: "number" },
                                longitude: { type: "number" }
                              },
                              required: ["latitude", "longitude"]
                            },
                            lat_lng: {
                              type: "object",
                              properties: {
                                latitude: { type: "number" },
                                longitude: { type: "number" }
                              },
                              required: ["latitude", "longitude"]
                            }
                          }
                        },
                        lat_lng: {
                          type: "object",
                          properties: {
                            latitude: { type: "number" },
                            longitude: { type: "number" }
                          },
                          required: ["latitude", "longitude"]
                        }
                      }
                    }
                  ]
                };
                output.parameters.properties.origin = waypointSchema;
                output.parameters.properties.destination = waypointSchema;
              }
            } else if (input.toolID === "maps_search_places") {
              output.description = (output.description || "") + 
                "\n\nCRITICAL INSTRUCTION: Each place returned in the response contains a 'googleMapsLinks' object (with 'placeUrl', 'directionsUrl', etc.) and an 'attribution.url'. You MUST always present these Google Maps URLs as clickable Markdown links (e.g. '[Google Maps](url)') alongside the name and description of each place in your final response to the user. Do not omit them.";
            }
          },
          "tool.execute.before": async (input, output) => {
            if (input.tool === "maps_compute_routes") {
              if (output.args) {
                if (typeof output.args.origin === "string") {
                  try {
                    const parsed = JSON.parse(output.args.origin);
                    if (parsed && typeof parsed === "object") {
                      output.args.origin = parsed;
                    } else {
                      output.args.origin = { address: output.args.origin };
                    }
                  } catch {
                    output.args.origin = { address: output.args.origin };
                  }
                }
                if (typeof output.args.destination === "string") {
                  try {
                    const parsed = JSON.parse(output.args.destination);
                    if (parsed && typeof parsed === "object") {
                      output.args.destination = parsed;
                    } else {
                      output.args.destination = { address: output.args.destination };
                    }
                  } catch {
                    output.args.destination = { address: output.args.destination };
                  }
                }
              }
            }
          }
        };
      }) satisfies Plugin;
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
