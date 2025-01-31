{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.direnv;
in {
  options.modules.tools.direnv = {
    enable = mkEnableOption "direnv configuration";
  };

  config = mkIf cfg.enable {
    programs.zsh.initExtra = ''
      function cd() {
        if [ "$#" -eq 0 ]; then
          builtin cd || return
        else
          builtin cd "$*" || return
        fi

        if [ -n "$VIRTUAL_ENV" ] && [[ ! "$PWD" =~ "$(dirname "$VIRTUAL_ENV")" ]]; then
          deactivate
        fi
        if [ -d ".venv" ]; then
          source .venv/bin/activate
        elif [ -d "venv" ]; then
          source venv/bin/activate
        fi
      }
    '';

    programs.bash.initExtra = ''
      function cd() {
        if [ "$#" -eq 0 ]; then
          builtin cd || return
        else
          builtin cd "$*" || return
        fi

        if [ -n "$VIRTUAL_ENV" ] && [[ ! "$PWD" =~ "$(dirname "$VIRTUAL_ENV")" ]]; then
          deactivate
        fi
        if [ -d ".venv" ]; then
          source .venv/bin/activate
        elif [ -d "venv" ]; then
          source venv/bin/activate
        fi
      }
    '';

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}