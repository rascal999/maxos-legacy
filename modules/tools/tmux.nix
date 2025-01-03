{ config, lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";  # Change prefix to Ctrl+a
    baseIndex = 1;   # Start windows numbering at 1
    escapeTime = 0;  # No delay for escape key press
    historyLimit = 50000;
    keyMode = "vi";  # Use vi keys
    
    extraConfig = ''
      # Enable mouse support
      set -g mouse on

      # Better split pane keys
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Easy config reload
      bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded"

      # Status bar customization
      set -g status-style bg=black,fg=white
      set -g window-status-current-style bg=white,fg=black,bold
      set -g status-interval 60
      set -g status-left-length 30
      set -g status-right "#{?window_zoomed_flag,🔍 ,}#[fg=yellow]#(cut -d ' ' -f 1-3 /proc/loadavg)#[default] #[fg=white]%H:%M#[default]"

      # Enable true color support
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Improve window management
      bind -n M-Left previous-window
      bind -n M-Right next-window
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5

      # Copy mode improvements
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible    # Sensible defaults
      yank        # Better copy/paste
      resurrect   # Session persistence
      continuum   # Continuous session saving
    ];
  };
}
