{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.open-webui;
in {
  options.modules.tools.open-webui = {
    enable = mkEnableOption "open-webui";
  };

  config = mkIf cfg.enable {
    # Configure Open WebUI service
  systemd.services.open-webui = {
    description = "Open WebUI for Ollama";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" "ollama.service" "ollama-volume-setup.service" ];
    after = [ "docker.service" "ollama.service" "ollama-volume-setup.service" ];

    serviceConfig = {
      Type = "exec";
      TimeoutStartSec = "600"; # 10 minutes for startup
      TimeoutStopSec = "60"; # 1 minute for shutdown
      ExecStartPre = [
        "${pkgs.docker}/bin/docker pull ghcr.io/open-webui/open-webui:main"
        ''${pkgs.docker}/bin/docker rm -f open-webui || true''
        # Add health check for ollama using bash
        "${pkgs.bash}/bin/bash -c 'until ${pkgs.curl}/bin/curl -s http://localhost:11434/api/version >/dev/null; do sleep 5; done'"
      ];
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --name open-webui \
          -v open-webui:/app/backend/data \
          -e OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api \
          -p 127.0.0.1:3002:8080 \
          --add-host host.docker.internal:host-gateway \
          --rm \
          ghcr.io/open-webui/open-webui:main
      '';
      ExecStop = "${pkgs.docker}/bin/docker stop open-webui";
      Restart = "always";
      RestartSec = "30s"; # Increased delay between restarts
    };
  };

  # Create Docker volume for persistence
  systemd.services.open-webui-volume-setup = {
    description = "Setup Open WebUI Docker volume";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    before = [ "open-webui.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker volume create open-webui";
    };
  };

  # Network creation service moved to a separate module
  };
}
