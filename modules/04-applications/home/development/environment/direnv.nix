{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.direnv;
in {
  options.maxos.tools.direnv = {
    enable = mkEnableOption "direnv configuration";
  };

  config = mkIf cfg.enable {
    programs.zsh.initContent = ''
      function find_and_activate_venv() {
        local current_dir="$PWD"
        while [[ "$current_dir" != "/" ]]; do
          if [[ -d "$current_dir/.venv" && -f "$current_dir/.venv/bin/activate" ]]; then
            source "$current_dir/.venv/bin/activate"
            return 0
          elif [[ -d "$current_dir/venv" && -f "$current_dir/venv/bin/activate" ]]; then
            source "$current_dir/venv/bin/activate"
            return 0
          fi
          current_dir="$(dirname "$current_dir")"
        done
        return 1
      }

      function check_venv() {
        # If we have an active virtualenv
        if [ -n "$VIRTUAL_ENV" ]; then
          # Get the directory containing the venv
          local venv_parent="$(dirname "$VIRTUAL_ENV")"
          
          # Deactivate if we're not in the venv directory tree
          if [[ ! "$PWD" =~ ^"$venv_parent".* ]]; then
            deactivate
            # Try to find and activate a different venv
            find_and_activate_venv
          fi
        else
          # No active venv, try to find and activate one
          find_and_activate_venv
        fi
      }

      # Hook into ZSH's chpwd function to handle all directory changes
      autoload -U add-zsh-hook
      add-zsh-hook chpwd check_venv

      # Override the cd command (for explicit cd usage)
      function cd() {
        if [ "$#" -eq 0 ]; then
          builtin cd || return
        else
          builtin cd "$@" || return
        fi
        check_venv || true  # Ignore errors from check_venv
      }

      # Create/override the .. shorthand
      function ..() {
        builtin cd .. || return
        check_venv || true  # Ignore errors from check_venv
      }

      # Ensure initial venv check when shell starts
      check_venv
    '';

    programs.bash.initExtra = ''
      function find_and_activate_venv() {
        local current_dir="$PWD"
        while [[ "$current_dir" != "/" ]]; do
          if [[ -d "$current_dir/.venv" && -f "$current_dir/.venv/bin/activate" ]]; then
            source "$current_dir/.venv/bin/activate"
            return 0
          elif [[ -d "$current_dir/venv" && -f "$current_dir/venv/bin/activate" ]]; then
            source "$current_dir/venv/bin/activate"
            return 0
          fi
          current_dir="$(dirname "$current_dir")"
        done
        return 1
      }

      function check_venv() {
        # If we have an active virtualenv
        if [ -n "$VIRTUAL_ENV" ]; then
          # Get the directory containing the venv
          local venv_parent="$(dirname "$VIRTUAL_ENV")"
          
          # Deactivate if we're not in the venv directory tree
          if [[ ! "$PWD" =~ ^"$venv_parent".* ]]; then
            deactivate
            # Try to find and activate a different venv
            find_and_activate_venv
          fi
        else
          # No active venv, try to find and activate one
          find_and_activate_venv
        fi
      }

      # For bash, we still need to override cd since it doesn't have chpwd
      function cd() {
        if [ "$#" -eq 0 ]; then
          builtin cd || return
        else
          builtin cd "$@" || return
        fi
        check_venv || true  # Ignore errors from check_venv
      }

      # Create/override the .. shorthand
      function ..() {
        builtin cd .. || return
        check_venv || true  # Ignore errors from check_venv
      }

      # Hook into PROMPT_COMMAND to handle directory changes
      PROMPT_COMMAND="check_venv;$PROMPT_COMMAND"
    '';

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}