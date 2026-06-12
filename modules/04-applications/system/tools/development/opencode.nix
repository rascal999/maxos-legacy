{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.opencode;

  dockerfile = pkgs.writeText "Dockerfile" ''
    FROM ghcr.io/anomalyco/opencode:latest
    RUN apk add --no-cache nodejs npm git bash openssh-client docker-cli tmux
  '';

  opencodePkg = pkgs.writeShellScriptBin "opencode" ''
    TEMPLATE_PATH="$HOME/.config/opencode/opencode.template.jsonc"
    CONFIG_PATH="$HOME/.config/opencode/opencode.jsonc"
    CONTEXT7_AUTHORIZATION=""

    # Fetch secrets securely from Bitwarden Secrets Manager if available
    if command -v bws &> /dev/null; then
      LOCAL_BWS_TOKEN="''${BWS_ACCESS_TOKEN:-}"
      if [ -z "$LOCAL_BWS_TOKEN" ] && command -v secret-tool &> /dev/null; then
        LOCAL_BWS_TOKEN=$(secret-tool lookup service bws-token account synlace 2>/dev/null || echo "")
      fi

      if [ -n "$LOCAL_BWS_TOKEN" ]; then
        echo "🔑 [Maxos] Securely retrieving keys from Bitwarden Secrets Manager..." >&2
        # Export temporarily to query bws
        export BWS_ACCESS_TOKEN="$LOCAL_BWS_TOKEN"
        export BWS_SERVER_URL="https://vault.bitwarden.eu"
        
        # Fetch secrets in one command to minimize round-trip network lag
        SECRET_DATA=$(bws secret list 2>/dev/null)
        if [ -n "$SECRET_DATA" ]; then
          # Resolve Linear API Key and export as LINEAR_API_KEY & LINEAR_ACCESS_TOKEN
          RESOLVED_LINEAR_KEY=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Linear API Key") | .value' 2>/dev/null || echo "")
          if [ -n "$RESOLVED_LINEAR_KEY" ]; then
            export LINEAR_API_KEY="$RESOLVED_LINEAR_KEY"
            export LINEAR_ACCESS_TOKEN="$RESOLVED_LINEAR_KEY"
            echo "✓ [Maxos] Successfully resolved Linear API Key." >&2
          else
            echo "⚠️ [Maxos] Warning: 'Linear API Key' not found in BWS project." >&2
            if [ "$1" = "serve" ]; then
              echo "❌ [Maxos] Error: Linear API Key is required for serve daemon. Exiting." >&2
              exit 1
            fi
          fi

          # Resolve Context7 API Key and format as Bearer token
          RESOLVED_C7_KEY=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Context7 API Key") | .value' 2>/dev/null || echo "")
          if [ -n "$RESOLVED_C7_KEY" ]; then
            CONTEXT7_AUTHORIZATION="Bearer $RESOLVED_C7_KEY"
            echo "✓ [Maxos] Successfully resolved Context7 API Key." >&2
          else
            echo "⚠️ [Maxos] Warning: 'Context7 API Key' not found in BWS project." >&2
          fi
        else
          echo "❌ [Maxos] Error: Failed to list secrets from BWS (invalid token or network error)." >&2
          if [ "$1" = "serve" ]; then
            exit 1
          fi
        fi

        # Immediately clean up BWS session variables from subshell environment
        unset BWS_ACCESS_TOKEN
        unset BWS_SERVER_URL
      else
        echo "⚠️ [Maxos] Warning: BWS access token not found in environment or OS Keyring. Secrets cannot be fetched." >&2
        if [ "$1" = "serve" ]; then
          exit 1
        fi
      fi
    else
      echo "⚠️ [Maxos] Warning: 'bws' CLI is not available in PATH. Secrets cannot be fetched." >&2
      if [ "$1" = "serve" ]; then
        exit 1
      fi
    fi

    # Dynamically generate opencode.jsonc from template on startup
    if [ -f "$TEMPLATE_PATH" ]; then
      mkdir -p "$(dirname "$CONFIG_PATH")"
      sed "s|@CONTEXT7_AUTHORIZATION@|''${CONTEXT7_AUTHORIZATION:-}|g" "$TEMPLATE_PATH" > "$CONFIG_PATH"
      chmod 600 "$CONFIG_PATH"
    fi

    # Ensure state/share directories exist on the host so Docker maps them with correct permissions
    mkdir -p "$HOME/.config/opencode"
    mkdir -p "$HOME/.local/share/opencode"
    mkdir -p "$HOME/.local/state/opencode"

    # Determine if we should allocate a TTY for interactive shell use
    TTY_FLAG=""
    if [ -t 0 ] && [ -t 1 ]; then
      TTY_FLAG="-t"
    fi

    # Resolve Host Docker GID to allow socket access inside the container
    DOCKER_GID=""
    if [ -S /var/run/docker.sock ]; then
      DOCKER_GID="--group-add $(stat -c '%g' /var/run/docker.sock)"
    fi

    # Setup SSH and Git identity mounts if they exist on the host
    SSH_MOUNT=""
    if [ -d "$HOME/.ssh" ]; then
      SSH_MOUNT="-v $HOME/.ssh:/home/user/.ssh:ro"
    fi
    GITCONFIG_MOUNT=""
    if [ -f "$HOME/.gitconfig" ]; then
      GITCONFIG_MOUNT="-v $HOME/.gitconfig:/home/user/.gitconfig:ro"
    fi

    # Run Docker wrapper with persistent workspace
    exec docker run \
      -i $TTY_FLAG \
      --rm \
      --network host \
      $DOCKER_GID \
      -v "/var/run/docker.sock:/var/run/docker.sock" \
      $SSH_MOUNT \
      $GITCONFIG_MOUNT \
      -v "$HOME/.config/opencode:/home/user/.config/opencode" \
      -v "$HOME/.local/share/opencode:/home/user/.local/share/opencode" \
      -v "$HOME/.local/state/opencode:/home/user/.local/state/opencode" \
      -v "/nix/store:/nix/store:ro" \
      -e HOME=/home/user \
      -e XDG_CACHE_HOME=/tmp/opencode-cache \
      -v "/home/user/git:/home/user/git" \
      -w "$PWD" \
      -e LINEAR_API_KEY="''${LINEAR_API_KEY:-}" \
      -e LINEAR_ACCESS_TOKEN="''${LINEAR_ACCESS_TOKEN:-}" \
      -e CONTEXT7_AUTHORIZATION="''${CONTEXT7_AUTHORIZATION:-}" \
      -e OPENCODE_SERVER_PASSWORD="''${OPENCODE_SERVER_PASSWORD:-}" \
      opencode-custom:latest "$@"
  '';
in {
  options.maxos.tools.opencode = {
    enable = mkEnableOption "opencode (OpenCode CLI)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      opencodePkg
      pkgs.bws
      pkgs.libsecret
    ];

    systemd.services.opencode-image-builder = {
      description = "Ensure opencode-custom Docker image is built";
      after = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "build-opencode-image" ''
          echo "🔧 [Maxos] Checking/building custom opencode Docker image..." >&2
          TEMP_DIR=$(mktemp -d)
          cp ${dockerfile} "$TEMP_DIR/Dockerfile"
          ${pkgs.docker}/bin/docker build -t opencode-custom:latest "$TEMP_DIR"
          rm -rf "$TEMP_DIR"
        '';
      };
    };
  };
}
