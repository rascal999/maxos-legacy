{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.openai-whisper;
in {
  options.modules.tools.openai-whisper = {
    enable = mkEnableOption "Enable OpenAI Whisper speech recognition";
    
    package = mkOption {
      type = types.package;
      default = pkgs.openai-whisper;
      description = "The OpenAI Whisper package to use";
    };
    
    models = mkOption {
      type = types.listOf types.str;
      default = [ "base" ];
      description = ''
        List of Whisper models to download.
        Available options: tiny, base, small, medium, large
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    
    # Add Python with necessary dependencies
    environment.systemPackages = with pkgs; [
      (python3.withPackages (ps: with ps; [
        torch
        numpy
        ffmpeg-python
      ]))
      ffmpeg
    ];
    
    # Create a setup script that downloads the specified models
    system.activationScripts.whisper-setup = ''
      mkdir -p /var/lib/whisper/models
      
      ${concatMapStringsSep "\n" (model: ''
        if [ ! -d "/var/lib/whisper/models/${model}" ]; then
          echo "Downloading Whisper ${model} model..."
          ${cfg.package}/bin/whisper --model ${model} --download-only
        fi
      '') cfg.models}
    '';
    
    # Set environment variables for Whisper
    environment.variables = {
      WHISPER_HOME = "/var/lib/whisper";
    };
  };
}