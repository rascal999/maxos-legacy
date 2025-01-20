{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    eza
    duf
    du-dust
  ];

  # tmux
  programs.tmux = {
    enable = true;
    historyLimit = 100000;
    terminal = "tmux-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    
    extraConfig = ''
      # Enable true color support
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g default-terminal "tmux-256color"
      
      # Pass through environment variables
      set -g update-environment "DISPLAY SSH_AUTH_SOCK SSH_CONNECTION WINDOWID XAUTHORITY TERM COLORTERM"
      set-environment -g COLORTERM "truecolor"
      
      # Ensure zsh picks up environment
      set -g default-command "${pkgs.zsh}/bin/zsh -l"
      
      # Key bindings
      bind "e" send-keys "exit" \; send-keys "Enter"
      bind "Enter" send-keys "eza --long --all --header --icons --git" \; send-keys "Enter"
      bind "l" send-keys "duf" \; send-keys "Enter"
      bind "r" send-keys "uname -a" \; send-keys "Enter"
      bind "Space" send-keys "eza --long --all --header --icons --git --sort=modified" \; send-keys "Enter"
      bind "Tab" send-keys "ls -alh" \; send-keys "Enter"
      bind "u" send-keys "dust ." \; send-keys "Enter"

      unbind C-b
      unbind [

      set -g prefix C-Space
      set -g mode-keys vi
      
      # Enable mouse support
      set -g mouse on'';

  };
}
