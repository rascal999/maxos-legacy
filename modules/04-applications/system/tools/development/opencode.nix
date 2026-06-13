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
    GMAIL_CLIENT_ID=""
    GMAIL_CLIENT_SECRET=""
    GMAIL_ACCESS_TOKEN=""
    GMAIL_REFRESH_TOKEN=""
    GOOGLE_ACCESS_TOKEN=""
    GOOGLE_REFRESH_TOKEN=""
    GOOGLE_MAPS_API_KEY=""

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
          # Print all available BWS key names for diagnostic purposes
          ALL_KEYS=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | .key' 2>/dev/null | paste -sd ", " -)
          echo "📝 [Maxos] Keys found in BWS project: $ALL_KEYS" >&2

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

          # Resolve Gmail Client ID and Secret from BWS
          RESOLVED_GMAIL_CLIENT_ID=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Gmail Client ID") | .value' 2>/dev/null | xargs || echo "")
          if [ -n "$RESOLVED_GMAIL_CLIENT_ID" ]; then
            GMAIL_CLIENT_ID="$RESOLVED_GMAIL_CLIENT_ID"
            echo "✓ [Maxos] Successfully resolved Gmail Client ID." >&2
          else
            echo "⚠️ [Maxos] Warning: 'Gmail Client ID' not found in BWS project." >&2
          fi

          RESOLVED_GMAIL_CLIENT_SECRET=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Gmail Client Secret") | .value' 2>/dev/null | xargs || echo "")
          if [ -n "$RESOLVED_GMAIL_CLIENT_SECRET" ]; then
            GMAIL_CLIENT_SECRET="$RESOLVED_GMAIL_CLIENT_SECRET"
            echo "✓ [Maxos] Successfully resolved Gmail Client Secret." >&2
          else
            echo "⚠️ [Maxos] Warning: 'Gmail Client Secret' not found in BWS project." >&2
          fi

          # Resolve Gmail Access and Refresh Tokens from BWS
          RESOLVED_GMAIL_ACCESS_TOKEN=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Gmail Access Token") | .value' 2>/dev/null | xargs || echo "")
          if [ -n "$RESOLVED_GMAIL_ACCESS_TOKEN" ]; then
            GMAIL_ACCESS_TOKEN="$RESOLVED_GMAIL_ACCESS_TOKEN"
            echo "✓ [Maxos] Successfully resolved Gmail Access Token." >&2
          fi

          RESOLVED_GMAIL_REFRESH_TOKEN=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Gmail Refresh Token") | .value' 2>/dev/null | xargs || echo "")
          if [ -n "$RESOLVED_GMAIL_REFRESH_TOKEN" ]; then
            GMAIL_REFRESH_TOKEN="$RESOLVED_GMAIL_REFRESH_TOKEN"
            echo "✓ [Maxos] Successfully resolved Gmail Refresh Token." >&2
          fi

          # Resolve Google Access and Refresh Tokens from BWS
          RESOLVED_GOOGLE_ACCESS_TOKEN=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Google Access Token") | .value' 2>/dev/null | xargs || echo "")
          if [ -n "$RESOLVED_GOOGLE_ACCESS_TOKEN" ]; then
            GOOGLE_ACCESS_TOKEN="$RESOLVED_GOOGLE_ACCESS_TOKEN"
            echo "✓ [Maxos] Successfully resolved Google Access Token." >&2
          fi

           RESOLVED_GOOGLE_REFRESH_TOKEN=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Google Refresh Token") | .value' 2>/dev/null | xargs || echo "")
          if [ -n "$RESOLVED_GOOGLE_REFRESH_TOKEN" ]; then
            GOOGLE_REFRESH_TOKEN="$RESOLVED_GOOGLE_REFRESH_TOKEN"
            echo "✓ [Maxos] Successfully resolved Google Refresh Token." >&2
          fi

          # Dynamically exchange Gmail/Google Refresh Token for a fresh temporary Access Token
          REF_TOKEN="''${GMAIL_REFRESH_TOKEN:-$GOOGLE_REFRESH_TOKEN}"
          if [ -n "$REF_TOKEN" ] && [ -n "$GMAIL_CLIENT_ID" ] && [ -n "$GMAIL_CLIENT_SECRET" ]; then
            echo "🔑 [Maxos] Exchanging Google/Gmail Refresh Token for a fresh Access Token..." >&2
            TOKEN_RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
              -d client_id="$GMAIL_CLIENT_ID" \
              -d client_secret="$GMAIL_CLIENT_SECRET" \
              -d refresh_token="$REF_TOKEN" \
              -d grant_type=refresh_token 2>/dev/null)
            
            EXTRACTED_ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | ${pkgs.jq}/bin/jq -r '.access_token' 2>/dev/null || echo "")
            if [ -n "$EXTRACTED_ACCESS_TOKEN" ] && [ "$EXTRACTED_ACCESS_TOKEN" != "null" ]; then
              GMAIL_ACCESS_TOKEN="$EXTRACTED_ACCESS_TOKEN"
              GOOGLE_ACCESS_TOKEN="$EXTRACTED_ACCESS_TOKEN"
              echo "✓ [Maxos] Successfully generated fresh Gmail Access Token." >&2
            else
              echo "⚠️ [Maxos] Warning: Failed to exchange Google Refresh Token. Response: $TOKEN_RESPONSE" >&2
            fi
          fi

          # Resolve Google Maps API Key from BWS
          RESOLVED_MAPS_KEY=$(echo "$SECRET_DATA" | ${pkgs.jq}/bin/jq -r '.[] | select(.key == "Google Maps API Key") | .value' 2>/dev/null | xargs || echo "")
          if [ -n "$RESOLVED_MAPS_KEY" ]; then
            GOOGLE_MAPS_API_KEY="$RESOLVED_MAPS_KEY"
            echo "✓ [Maxos] Successfully resolved Google Maps API Key." >&2
          else
            echo "⚠️ [Maxos] Warning: 'Google Maps API Key' not found in BWS project." >&2
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
      sed \
        -e "s|@CONTEXT7_AUTHORIZATION@|''${CONTEXT7_AUTHORIZATION:-}|g" \
        -e "s|@GMAIL_CLIENT_ID@|''${GMAIL_CLIENT_ID:-}|g" \
        -e "s|@GMAIL_CLIENT_SECRET@|''${GMAIL_CLIENT_SECRET:-}|g" \
        -e "s|@GMAIL_ACCESS_TOKEN@|''${GMAIL_ACCESS_TOKEN:-}|g" \
        -e "s|@GOOGLE_MAPS_API_KEY@|''${GOOGLE_MAPS_API_KEY:-}|g" \
        "$TEMPLATE_PATH" > "$CONFIG_PATH"
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
      -e GMAIL_CLIENT_ID="''${GMAIL_CLIENT_ID:-}" \
      -e GMAIL_CLIENT_SECRET="''${GMAIL_CLIENT_SECRET:-}" \
      -e GMAIL_ACCESS_TOKEN="''${GMAIL_ACCESS_TOKEN:-}" \
      -e GMAIL_REFRESH_TOKEN="''${GMAIL_REFRESH_TOKEN:-}" \
      -e GOOGLE_ACCESS_TOKEN="''${GOOGLE_ACCESS_TOKEN:-}" \
      -e GOOGLE_REFRESH_TOKEN="''${GOOGLE_REFRESH_TOKEN:-}" \
      -e GOOGLE_MAPS_API_KEY="''${GOOGLE_MAPS_API_KEY:-}" \
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
