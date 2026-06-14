{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.opencode;

  opencodePkg = pkgs.writeShellScriptBin "opencode" ''
    ORCHESTRATOR_PATH="$HOME/git/github/opencode-orchestrator"

    # 0. Self-healing image compilation: Check if image has our custom entrypoint, if not, build/update it from the orchestrator repo!
    if ! docker inspect opencode-custom:latest &>/dev/null || [ "$(docker inspect --format='{{.Config.Entrypoint}}' opencode-custom:latest 2>/dev/null)" != "[/usr/local/bin/entrypoint.sh]" ]; then
      if [ -d "$ORCHESTRATOR_PATH" ]; then
        echo "🔧 [Maxos] Building/updating custom opencode Docker image from opencode-orchestrator..." >&2
        docker build -t opencode-custom:latest "$ORCHESTRATOR_PATH" >&2
      else
        echo "❌ [Maxos] Error: 'opencode-orchestrator' repository not found at '$ORCHESTRATOR_PATH'. Cannot compile custom image." >&2
        exit 1
      fi
    fi

    # 1. Recreate/repair repository symlinks to match the host's actual HOME directory
    if [ -d ".opencode" ]; then
      echo "🔧 [Maxos] Re-aligning repository overlay symlinks to host $HOME..." >&2
      mkdir -p .opencode/commands .opencode/prompts/agents .opencode/instructions

      # Clean up existing symlinks
      rm -f .opencode/commands/upstream .opencode/commands/custom
      rm -f .opencode/prompts/agents/upstream .opencode/prompts/agents/custom
      rm -f .opencode/instructions/custom-rules.md

      # Create host-aligned symlinks
      ln -sf "$HOME/.config/opencode/ecc-upstream/.opencode/commands" .opencode/commands/upstream
      ln -sf "$HOME/.config/opencode/ecc-custom/commands" .opencode/commands/custom
      ln -sf "$HOME/.config/opencode/ecc-upstream/.opencode/prompts/agents" .opencode/prompts/agents/upstream
      ln -sf "$HOME/.config/opencode/ecc-custom/prompts/agents" .opencode/prompts/agents/custom
      ln -sf "$HOME/.config/opencode/ecc-custom/instructions/CORPORATE_STANDARDS.md" .opencode/instructions/custom-rules.md
    fi

    # 2. Securely resolve BWS_ACCESS_TOKEN on host
    LOCAL_BWS_TOKEN="''${BWS_ACCESS_TOKEN:-}"
    if [ -z "$LOCAL_BWS_TOKEN" ] && command -v secret-tool &> /dev/null; then
      LOCAL_BWS_TOKEN=$(secret-tool lookup service bws-token account synlace 2>/dev/null || echo "")
    fi

    # Determine TTY allocating
    TTY_FLAG=""
    if [ -t 0 ] && [ -t 1 ]; then
      TTY_FLAG="-t"
    fi

    # Resolve Docker GID
    DOCKER_GID=""
    if [ -S /var/run/docker.sock ]; then
      DOCKER_GID="--group-add $(stat -c '%g' /var/run/docker.sock)"
    fi

    GITCONFIG_MOUNT=""
    if [ -f "$HOME/.gitconfig" ]; then
      GITCONFIG_MOUNT="-v $HOME/.gitconfig:/home/user/.gitconfig:ro"
    fi
    GH_MOUNT=""
    if [ -d "$HOME/.config/gh" ]; then
      GH_MOUNT="-v $HOME/.config/gh:/home/user/.config/gh:ro"
    fi

    # Run the containerized opencode
    exec docker run \
      -i $TTY_FLAG \
      --rm \
      --network host \
      $DOCKER_GID \
      -v "/var/run/docker.sock:/var/run/docker.sock" \
      $GITCONFIG_MOUNT \
      $GH_MOUNT \
      -v "$HOME/.config/opencode:/home/user/.config/opencode" \
      -v "$HOME/.local/share/opencode:/home/user/.local/share/opencode" \
      -v "$HOME/.local/state/opencode:/home/user/.local/state/opencode" \
      -v "/nix/store:/nix/store:ro" \
      -e HOME=/home/user \
      -e XDG_CACHE_HOME=/tmp/opencode-cache \
      -v "/home/user/git:/home/user/git" \
      -w "$PWD" \
      -e BWS_ACCESS_TOKEN="$LOCAL_BWS_TOKEN" \
      -e OPENCODE_SERVER_PASSWORD="''${OPENCODE_SERVER_PASSWORD:-}" \
      -e LINEAR_API_KEY="''${LINEAR_API_KEY:-}" \
      -e LINEAR_ACCESS_TOKEN="''${LINEAR_ACCESS_TOKEN:-}" \
      -e GITHUB_TOKEN="''${GITHUB_TOKEN:-}" \
      -e OPENROUTER_API_KEY="''${OPENROUTER_API_KEY:-}" \
      -e CONTEXT7_AUTHORIZATION="''${CONTEXT7_AUTHORIZATION:-}" \
      -e GMAIL_CLIENT_ID="''${GMAIL_CLIENT_ID:-}" \
      -e GMAIL_CLIENT_SECRET="''${GMAIL_CLIENT_SECRET:-}" \
      -e GMAIL_REFRESH_TOKEN="''${GMAIL_REFRESH_TOKEN:-}" \
      -e GOOGLE_REFRESH_TOKEN="''${GOOGLE_REFRESH_TOKEN:-}" \
      -e GMAIL_ACCESS_TOKEN="''${GMAIL_ACCESS_TOKEN:-}" \
      -e GOOGLE_ACCESS_TOKEN="''${GOOGLE_ACCESS_TOKEN:-}" \
      -e GOOGLE_MAPS_API_KEY="''${GOOGLE_MAPS_API_KEY:-}" \
      -e OPENCODE_MODEL="''${OPENCODE_MODEL:-}" \
      -e SSH_PRIVATE_KEY="''${SSH_PRIVATE_KEY:-}" \
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
  };
}