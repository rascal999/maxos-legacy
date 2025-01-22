{ config, lib, pkgs, ... }:

{
  options.services.ollama = {
    enable = lib.mkEnableOption "Ollama LLM service";
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["deepseek-ai/deepseek-r1-7b-chat"];
      description = "Initial models to download";
    };
  };

  config = lib.mkIf config.services.ollama.enable {
    # Removed duplicate service.ollama.enable declaration
    systemd.services.ollama = {
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.ollama}/bin/ollama serve";
        Environment = "OLLAMA_HOST=127.0.0.1:11434";
        DeviceAllow = [
          "/dev/nvidiactl rw"
          "/dev/nvidia-uvm rw"
          "/dev/nvidia0 rw"
        ];
        RestrictAddressFamilies = "AF_INET";
        DynamicUser = true;
        StateDirectory = "ollama";
      };
      postStart = let
        modelScript = pkgs.writeScriptBin "get-models" ''
          ${lib.concatMapStrings (model: ''
            ${pkgs.curl}/bin/curl -s -X POST http://localhost:11434/api/pull -d '{"name":"${model}"}'
          '') config.services.ollama.models}
        '';
      in "${modelScript}/bin/get-models";
    };

    environment.systemPackages = [pkgs.ollama];
  };
}
