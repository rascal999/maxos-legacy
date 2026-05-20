{ config, lib, pkgs, nix-openclaw ? null, ... }:

with lib;

let
  cfg = config.maxos.tools.openclaw;
in {
  # Import the nix-openclaw Home Manager module unconditionally at the top level.
  # imports cannot be inside mkIf — they are evaluated before options are resolved.
  # The module is a no-op unless programs.openclaw.enable = true.
  imports = lib.optionals (nix-openclaw != null) [
    nix-openclaw.homeManagerModules.openclaw
  ];

  options.maxos.tools.openclaw = {
    enable = mkEnableOption "OpenClaw AI gateway (multi-channel AI messaging hub)";

    model = mkOption {
      type = types.str;
      default = "anthropic/claude-opus-4-6";
      description = "Default model for OpenClaw agents (provider/model format)";
    };

    anthropicKeyFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Path to a file containing the Anthropic API key.
        For SOPS-managed secrets, use the SOPS-decrypted path e.g. /run/secrets/anthropic_api_key.
        If null, OpenClaw will fall back to the ANTHROPIC_API_KEY environment variable.
      '';
    };

    openaiKeyFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Path to a file containing the OpenAI API key.
        For SOPS-managed secrets, use the SOPS-decrypted path e.g. /run/secrets/openai_api_key.
        If null, OpenClaw will fall back to the OPENAI_API_KEY environment variable.
      '';
    };
  };

  config = mkIf (cfg.enable && nix-openclaw != null) {
    programs.openclaw = {
      enable = true;

      config = {
        # Default model provider and model
        agents.defaults.model.primary = cfg.model;

        # SecretRef-backed API keys — resolved from files at runtime.
        # In Nix mode (OPENCLAW_NIX_MODE=1, set automatically by nix-openclaw),
        # openclaw.json is immutable; all auth must be declared here.
        # Schema: { source = "file"; provider = "default"; id = "<path>"; }
        models.providers = mkMerge [
          (mkIf (cfg.anthropicKeyFile != null) {
            anthropic.apiKey = {
              source = "file";
              provider = "default";
              id = cfg.anthropicKeyFile;
            };
          })
          (mkIf (cfg.openaiKeyFile != null) {
            openai.apiKey = {
              source = "file";
              provider = "default";
              id = cfg.openaiKeyFile;
            };
          })
        ];
      };
    };
  };
}
