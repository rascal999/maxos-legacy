{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.direnv;
in {
  options.modules.tools.direnv = {
    enable = mkEnableOption "direnv configuration";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = ''
        # Auto-source Python venv if it exists
        layout_python() {
          local venv=.venv
          if [ -d "$venv" ]; then
            source $venv/bin/activate
          fi
        }

        # Auto-detect Python projects
        has_python_project() {
          test -e setup.py -o -e requirements.txt -o -e pyproject.toml
        }

        if has_python_project; then
          layout python
        fi
      '';
    };
  };
}