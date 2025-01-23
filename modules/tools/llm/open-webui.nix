{ config, lib, pkgs, ... }:

{
  # Configure Open WebUI service
  systemd.services.open-webui = {
    description = "Open WebUI for Ollama";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" "ollama.service" ];
    after = [ "docker.service" "ollama.service" ];

    serviceConfig = {
      Type = "exec";
      ExecStartPre = [
        "${pkgs.docker}/bin/docker pull ghcr.io/open-webui/open-webui:main"
        ''${pkgs.docker}/bin/docker rm -f open-webui || true''
      ];
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --name open-webui \
          -v open-webui:/app/backend/data \
          -e OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api \
          -p 127.0.0.1:3000:8080 \
          --add-host host.docker.internal:host-gateway \
          --rm \
          ghcr.io/open-webui/open-webui:main
      '';
      ExecStop = "${pkgs.docker}/bin/docker stop open-webui";
      Restart = "always";
      RestartSec = "10s";
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
}
