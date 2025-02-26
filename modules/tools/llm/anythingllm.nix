{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.anythingllm;
  uid = 1000;
  gid = 1000;
  secretsPath = "/home/user/git/github/monorepo/secrets/environments/mgp/env";
in {
  options.modules.tools.anythingllm = {
    enable = mkEnableOption "anythingllm";
    port = mkOption {
      type = types.port;
      default = 3001;
      description = "Port to run AnythingLLM on";
    };
    storageLocation = mkOption {
      type = types.str;
      default = "/var/lib/anythingllm";
      description = "Location to store AnythingLLM data";
    };
    openRouterApiKeyFile = mkOption {
      type = types.str;
      default = "";
      description = "Path to file containing OpenRouter API key for AnythingLLM agents";
    };
  };

  config = mkIf cfg.enable {
    # Create storage directory and set ownership/permissions first
    systemd.tmpfiles.rules = [
      "d ${cfg.storageLocation} 0755 ${toString uid} ${toString gid} -"
      "d ${cfg.storageLocation}/plugins 0755 ${toString uid} ${toString gid} -"
      "d ${cfg.storageLocation}/plugins/agent-skills 0755 ${toString uid} ${toString gid} -"
      "d ${cfg.storageLocation}/plugins/agent-flows 0755 ${toString uid} ${toString gid} -"
      "d ${cfg.storageLocation}/secrets 0755 ${toString uid} ${toString gid} -"
      "f ${cfg.storageLocation}/anythingllm.db 0666 ${toString uid} ${toString gid} -"
      "f ${cfg.storageLocation}/jwt_secret 0644 ${toString uid} ${toString gid} -"
      "f ${cfg.storageLocation}/openrouter_api_key 0644 ${toString uid} ${toString gid} -"
    ];

    # Mount unit for agent skills
    systemd.mounts = [
      {
        what = "/home/user/git/github/monorepo/tools/anythingllm/agent-skills";
        where = "${cfg.storageLocation}/plugins/agent-skills";
        type = "none";
        options = "bind";
        wantedBy = [ "multi-user.target" ];
        requiredBy = [ "anythingllm.service" ];
      }
      # Mount secrets directory
      {
        what = secretsPath;
        where = "${cfg.storageLocation}/secrets/env";
        type = "none";
        options = "bind";
        wantedBy = [ "multi-user.target" ];
        requiredBy = [ "anythingllm.service" ];
      }
    ];

    systemd.services.anythingllm = {
      description = "AnythingLLM Service";
      wantedBy = [ "multi-user.target" ];
      requires = [
        "docker.service"
        "ollama.service"
        "network-online.target"
      ];
      after = [
        "docker.service"
        "ollama.service"
        "systemd-tmpfiles-setup.service"
        "network-online.target"
      ];

      serviceConfig = {
        Type = "exec";
        User = "anythingllm";
        Group = "anythingllm";
        TimeoutStartSec = "20m";
        TimeoutStopSec = "5m";
        Restart = "on-failure";
        RestartSec = "30s";
        ExecStartPre = [
          # Create and set up storage directory
          "+${pkgs.coreutils}/bin/mkdir -p ${cfg.storageLocation}"
          "+${pkgs.coreutils}/bin/touch ${cfg.storageLocation}/anythingllm.db"
          "+${pkgs.coreutils}/bin/chown -R ${toString uid}:${toString gid} ${cfg.storageLocation}"
          "+${pkgs.coreutils}/bin/chmod 755 ${cfg.storageLocation}"
          "+${pkgs.coreutils}/bin/chmod 666 ${cfg.storageLocation}/anythingllm.db"
          
          # Set up JWT secret
          "+${pkgs.bash}/bin/bash -c '[ -f ${cfg.storageLocation}/jwt_secret ] || ${pkgs.openssl}/bin/openssl rand -hex 32 > ${cfg.storageLocation}/jwt_secret'"
          "+${pkgs.coreutils}/bin/chmod 644 ${cfg.storageLocation}/jwt_secret"
          "+${pkgs.coreutils}/bin/chown ${toString uid}:${toString gid} ${cfg.storageLocation}/jwt_secret"
          
          # Set up OpenRouter API key file
          "+${pkgs.bash}/bin/bash -c '[ -f ${cfg.storageLocation}/openrouter_api_key ] || echo \"\" > ${cfg.storageLocation}/openrouter_api_key'"
          "+${pkgs.coreutils}/bin/chmod 644 ${cfg.storageLocation}/openrouter_api_key"
          "+${pkgs.coreutils}/bin/chown ${toString uid}:${toString gid} ${cfg.storageLocation}/openrouter_api_key"
          
          # Create plugins directory structure
          "+${pkgs.coreutils}/bin/mkdir -p ${cfg.storageLocation}/plugins"
          "+${pkgs.coreutils}/bin/mkdir -p ${cfg.storageLocation}/plugins/agent-flows"
          "+${pkgs.coreutils}/bin/mkdir -p ${cfg.storageLocation}/secrets"
          "+${pkgs.coreutils}/bin/chown -R ${toString uid}:${toString gid} ${cfg.storageLocation}/plugins"
          "+${pkgs.coreutils}/bin/chmod -R 755 ${cfg.storageLocation}/plugins"
          "+${pkgs.coreutils}/bin/chown -R ${toString uid}:${toString gid} ${cfg.storageLocation}/secrets"
          "+${pkgs.coreutils}/bin/chmod -R 755 ${cfg.storageLocation}/secrets"
          
          # Docker operations with retry
          "+${pkgs.bash}/bin/bash -c 'until ${pkgs.docker}/bin/docker pull mintplexlabs/anythingllm; do echo Retrying pull in 30s; sleep 30; done'"
          "${pkgs.docker}/bin/docker rm -f anythingllm || true"
        ];
        ExecStart = pkgs.writeShellScript "start-anythingllm" ''
          JWT_SECRET=$(cat ${cfg.storageLocation}/jwt_secret)
          # If a specific OpenRouter API key file is provided, use it
          ${lib.optionalString (cfg.openRouterApiKeyFile != "") "OPENROUTER_API_KEY=$(cat ${cfg.openRouterApiKeyFile})"}
          # Otherwise, try to read from the default location if it exists and is not empty
          ${lib.optionalString (cfg.openRouterApiKeyFile == "") ''
          if [ -s ${cfg.storageLocation}/openrouter_api_key ]; then
            OPENROUTER_API_KEY=$(cat ${cfg.storageLocation}/openrouter_api_key)
          fi
          ''}
          # Run the Docker container with all necessary parameters
          ${pkgs.docker}/bin/docker run --name anythingllm --cap-add SYS_ADMIN -p ${toString cfg.port}:3001 \
            -v ${cfg.storageLocation}:/app/server/storage \
            -v ${cfg.storageLocation}/plugins:/app/server/storage/plugins \
            -v ${cfg.storageLocation}/secrets:/app/server/storage/secrets \
            -e STORAGE_DIR="/app/server/storage" \
            -e SECRETS_PATH="/app/server/storage/secrets/env" \
            -e JWT_SECRET="$JWT_SECRET" \
            -e LLM_PROVIDER=ollama \
            -e OLLAMA_BASE_PATH=http://host.docker.internal:11434 \
            -e OLLAMA_MODEL_PREF=llama2 \
            -e OLLAMA_MODEL_TOKEN_LIMIT=4096 \
            -e EMBEDDING_ENGINE=ollama \
            -e EMBEDDING_BASE_PATH=http://host.docker.internal:11434 \
            -e EMBEDDING_MODEL_PREF=nomic-embed-text:latest \
            -e EMBEDDING_MODEL_MAX_CHUNK_LENGTH=8192 \
            -e VECTOR_DB=lancedb \
            -e WHISPER_PROVIDER=local \
            -e TTS_PROVIDER=native \
            -e PASSWORDMINCHAR=12 \
            -e AGENT_LLM_PROVIDER=openrouter \
            -e OPENROUTER_MODEL_PREF=anthropic/claude-3.7-sonnet:beta \
            -e OPENROUTER_API_KEY="$OPENROUTER_API_KEY" \
            --add-host=host.docker.internal:host-gateway \
            --user ${toString uid}:${toString gid} \
            mintplexlabs/anythingllm
        '';
        ExecStop = "${pkgs.docker}/bin/docker stop anythingllm";
      };
    };

    # Create anythingllm user and group with specific UID/GID
    users.users.anythingllm = {
      isSystemUser = true;
      group = "anythingllm";
      home = cfg.storageLocation;
      createHome = true;
      description = "AnythingLLM service user";
      extraGroups = [ "docker" ];
      uid = uid;
    };

    users.groups.anythingllm = {
      gid = gid;
    };

    # Ensure Docker is enabled
    virtualisation.docker.enable = true;
  };
}