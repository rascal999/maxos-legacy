{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.zsh;
in {
  options.modules.tools.zsh = {
    enable = mkEnableOption "Zsh shell with custom configuration";
    
    monorepoDirectory = mkOption {
      type = types.str;
      default = "/home/user/git/github/monorepo";
      description = "Path to the main monorepo directory";
    };
    
    workspaceDirectory = mkOption {
      type = types.str;
      default = "/home/user/monorepo/tools/goose/workspace";
      description = "Default workspace directory";
    };
  };

  config = mkIf cfg.enable {
  home.packages = with pkgs; [
    mcfly  # Shell history search
    grc    # Generic colouriser
    lazygit # Terminal UI for git
    zsh-powerlevel10k  # For p10k command
    libnotify  # For desktop notifications
    xdotool    # For window focus detection
  ];

  home.file.".p10k.zsh".source = ./zsh/p10k.zsh;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 100000;
      save = 100000;
      path = "$HOME/.local/share/zsh/history";
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = false;  # Disable sharing to prevent race conditions
    };

    initExtra = ''
      # Set terminal font
      if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "alacritty" ]]; then
        POWERLEVEL9K_MODE='nerdfont-complete'
      fi

      # History setup and repair (before instant prompt)
      historySetup() {
        local histdir="$HOME/.local/share/zsh"
        local histfile="$histdir/history"
        
        mkdir -p "$histdir" 2>/dev/null
        
        if [[ -f "$histfile" ]] && ! fc -R "$histfile" >/dev/null 2>&1; then
          mv "$histfile" "$histfile.corrupt-$(date +%Y%m%d-%H%M%S)" 2>/dev/null
          touch "$histfile" 2>/dev/null
        fi
        
        [[ -f "$histfile" ]] || touch "$histfile" 2>/dev/null
        chmod 600 "$histfile" 2>/dev/null
      }
      historySetup >/dev/null 2>&1

      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Initialize Powerlevel10k with proper font
      if [[ -f ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme ]]; then
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        # Configure basic p10k settings if no config exists
        if [[ ! -f ~/.p10k.zsh ]]; then
          POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
          POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs time)
          POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
          POWERLEVEL9K_MODE='nerdfont-complete'
        fi
      fi

      # Source p10k config if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

      # Source baseimage .env file
      function se() {
        local env_file="${cfg.monorepoDirectory}/docker/baseimage/.env"
        if [[ -f "$env_file" ]]; then
          setopt NO_NOMATCH
          echo "Sourcing environment variables:"
          grep -v '^#' "$env_file" | while IFS='=' read -r key value; do
            if [[ -n "$key" ]]; then
              eval "export $key=$value"
              echo "$key"
            fi
          done
          unsetopt NO_NOMATCH
        else
          echo "Error: baseimage .env file not found at $env_file"
          return 1
        fi
      }

      # Command execution time tracking and notification
      # Only initialize if not already set (to avoid resetting during sourcing)
      [[ -z "$__cmd_timestamp" ]] && __cmd_timestamp=0
      [[ -z "$__cmd_command" ]] && __cmd_command=""
      [[ -z "$__terminal_focused" ]] && __terminal_focused=1
      
      # Store the terminal window ID for focus comparison
      __terminal_window_id=""
      
      # Get terminal window ID
      function get_terminal_window_id() {
        if command -v xdotool >/dev/null 2>&1; then
          __terminal_window_id=$(xdotool getactivewindow 2>/dev/null)
        fi
      }
      
      # Check if terminal window is currently focused
      function check_terminal_focus() {
        if command -v xdotool >/dev/null 2>&1 && [[ -n "$__terminal_window_id" ]]; then
          local active_window=$(xdotool getactivewindow 2>/dev/null)
          if [[ "$active_window" == "$__terminal_window_id" ]]; then
            __terminal_focused=1
          else
            __terminal_focused=0
          fi
        else
          __terminal_focused=1  # Assume focused if xdotool not available
        fi
      }
      
      function preexec() {
        __cmd_timestamp=$SECONDS
        __cmd_command="$1"
        # Store the terminal window ID when command starts
        get_terminal_window_id
        __terminal_focused=1  # Assume focused at start
      }
      
      function precmd() {
        local exit_code=$?
        local duration=$((SECONDS - __cmd_timestamp))
        
        # Check if terminal is currently focused (at command completion)
        check_terminal_focus
        
        # Only notify if command took more than 3 seconds and terminal is NOT focused now
        if [[ $duration -gt 3 && $__terminal_focused -eq 0 && -n "$__cmd_command" ]]; then
          local status_msg
          local urgency="normal"
          
          if [[ $exit_code -eq 0 ]]; then
            status_msg="✅ Command completed successfully"
          else
            status_msg="❌ Command failed (exit code: $exit_code)"
            urgency="critical"
          fi
          
          # Format duration
          local duration_str
          if [[ $duration -ge 3600 ]]; then
            duration_str="$(($duration / 3600))h $(($duration % 3600 / 60))m $(($duration % 60))s"
          elif [[ $duration -ge 60 ]]; then
            duration_str="$(($duration / 60))m $(($duration % 60))s"
          else
            duration_str="''${duration}s"
          fi
          
          # Truncate command if too long
          local cmd_display="$__cmd_command"
          if [[ ''${#cmd_display} -gt 50 ]]; then
            cmd_display="''${cmd_display:0:47}..."
          fi
          
          # Send notification
          if command -v notify-send >/dev/null 2>&1; then
            notify-send \
              --urgency="$urgency" \
              --expire-time=5000 \
              --app-name="Terminal" \
              "$status_msg" \
              "Command: $cmd_display\nDuration: $duration_str"
          fi
        fi
        
        # Reset variables
        __cmd_command=""
        __terminal_focused=1
      }

      # Copy most recent download to current directory
      function cpd() {
        local last_download
        last_download=$(ls -t ~/Downloads | head -1)
        if [[ -n "$last_download" ]]; then
          cp -v ~/Downloads/"$last_download" .
          echo "\nCurrent directory contents:"
          ls -la
        else
          echo "No files found in ~/Downloads"
        fi
      }

      # Copy most recent download to goose workspace
      function cpw() {
        local last_download
        local workspace_dir="${cfg.workspaceDirectory}"
        last_download=$(ls -t ~/Downloads | head -1)
        if [[ -n "$last_download" ]]; then
          cp -v ~/Downloads/"$last_download" "$workspace_dir/"
          echo "\nWorkspace directory contents:"
          ls -la "$workspace_dir"
        else
          echo "No files found in ~/Downloads"
        fi
      }

      # Generate and optionally execute commands using fabric
      function fabric_cmd() {
        # Check if a prompt was provided
        if [[ -z "$1" ]]; then
          echo "Error: No prompt provided."
          echo "Usage: fabric_cmd your prompt here"
          return 1
        fi

        # Combine all arguments into a single prompt
        local prompt="$*"
        
        # Generate the command using fabric
        local cmd=$(echo "$prompt" | fabric -p create_command)
        
        # Display the generated command
        echo "\nGenerated command:"
        echo "----------------------------------------"
        echo "$cmd"
        echo "----------------------------------------"
        
        # Ask for confirmation before executing (N is default)
        echo -n "Execute this command? (y/N): "
        read confirm
        
        # Execute if confirmed with 'y' or 'Y', otherwise don't execute (default)
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
          echo "\nExecuting command..."
          eval "$cmd"
          echo "\nCommand execution completed."
        else
          echo "\nCommand not executed."
        fi
      }
      
      # Simple alias for fabric command generation
      function f() {
        fabric_cmd "$@"
      }

      # Create and enter new project directory
      function cum() {
        ${pkgs.bash}/bin/bash ${cfg.monorepoDirectory}/docker/baseimage/create_project.sh "$@"
        if [ -f /tmp/cum_last_project ]; then
          cd "$(cat /tmp/cum_last_project)"
          rm /tmp/cum_last_project
        fi
      }

      # TMUX hostname-based window naming
      function ssh() {
        # Store original window name if in tmux
        if [[ -n "$TMUX" ]]; then
          local original_name=$(tmux display-message -p '#W')
          
          # Extract hostname from ssh command
          local hostname=""
          for arg in "$@"; do
            if [[ "$arg" != -* ]]; then
              hostname="$arg"
              break
            fi
          done
          
          # Set window name to remote hostname
          if [[ -n "$hostname" ]]; then
            tmux rename-window "$hostname"
          fi
          
          # Call actual ssh command
          command ssh "$@"
          local ssh_exit_code=$?
          
          # Restore original window name after ssh exits
          tmux rename-window "$original_name"
          
          return $ssh_exit_code
        else
          # Not in tmux, just call ssh normally
          command ssh "$@"
        fi
      }

      # Function to manually update tmux window name with current hostname
      function tmux_update_hostname() {
        if [[ -n "$TMUX" ]]; then
          local current_hostname=$(hostname -s)
          tmux rename-window "$current_hostname"
        else
          echo "Not in a tmux session"
        fi
      }

      # Alias for quick hostname update
      alias tuh='tmux_update_hostname'
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "colorize" ];
    };

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      dig = "grc dig";
      id = "grc id";
      ps = "grc ps";
      lg = "lazygit";
      ff = "firefox";
      ls = "grc ls";
      f = "fabric_cmd";
      k = "kubectl";
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];
    };
  };
}
