{ config, pkgs, lib, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    
    # Common functions and settings
    stdlib = ''
      # Configure direnv settings
      : ''${DIRENV_LOG_FORMAT:=""}
      : ''${DIRENV_WARN_TIMEOUT:="5s"}
      
      # Enable logging and layout directory management
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          echo -n "$XDG_CACHE_HOME"/direnv/layouts/
          echo -n "$PWD" | shasum | cut -d ' ' -f 1
        )}"
      }

      # Load a .env file if it exists
      dotenv_if_exists() {
        local path="$1"
        if [[ -f "''${path}" ]]; then
          watch_file "''${path}"
          dotenv "''${path}"
        fi
      }

      # Use a local bin directory
      use_local_bin() {
        PATH_add "''${PWD}/bin"
      }

      # Load node version from .nvmrc
      use_nvm() {
        local node_version="$(cat .nvmrc 2>/dev/null)"
        if [[ -n "''${node_version}" ]]; then
          use node "''${node_version}"
        fi
      }

      # Load python version from .python-version
      use_pyenv() {
        local python_version="$(cat .python-version 2>/dev/null)"
        if [[ -n "''${python_version}" ]]; then
          use python "''${python_version}"
        fi
      }

      # Create and load a virtual environment in .venv
      layout_python() {
        local python=''${1:-python3}
        [[ $# -gt 0 ]] && shift
        if [[ ! -d .venv ]]; then
          log_status "Creating virtual environment..."
          $python -m venv .venv "$@"
        fi
        source .venv/bin/activate
      }

      # Load environment variables from .env files
      dotenv_if_exists .env
      dotenv_if_exists .env.local
      dotenv_if_exists .env.''${DIRENV_ENV:-development}
    '';
  };

  # Create common .envrc templates
  xdg.configFile = {
    "direnv/templates/nix.envrc".text = ''
      # Nix development environment
      use flake
      
      # Load environment variables
      dotenv_if_exists .env
      dotenv_if_exists .env.local
      
      # Add local bin to PATH
      PATH_add bin
    '';

    "direnv/templates/node.envrc".text = ''
      # Node.js development environment
      use nvm
      
      # Load environment variables
      dotenv_if_exists .env
      dotenv_if_exists .env.local
      
      # Add node_modules/.bin to PATH
      PATH_add node_modules/.bin
      
      # Add local bin to PATH
      PATH_add bin
    '';

    "direnv/templates/python.envrc".text = ''
      # Python development environment
      use pyenv
      layout python
      
      # Load environment variables
      dotenv_if_exists .env
      dotenv_if_exists .env.local
      
      # Add local bin to PATH
      PATH_add bin
    '';
  };
}
