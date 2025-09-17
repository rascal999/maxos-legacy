{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.maxos.tools.tmux;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # Tmux has no hard dependencies
  
in {
  options.maxos.tools.tmux = {
    enable = mkEnableOption "Tmux terminal multiplexer";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
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
    
   plugins = [
     pkgs.tmuxPlugins.sensible
     pkgs.tmuxPlugins.open
     pkgs.tmuxPlugins.yank
     {
       plugin = pkgs.tmuxPlugins.resurrect;
       extraConfig = "set -g @resurrect-strategy-nvim 'session'";
     }
   ];

   extraConfig = ''
     # Enable true color support
     set -ag terminal-overrides ",xterm-256color:RGB"
     set -g default-terminal "tmux-256color"
     
     # Pass through environment variables
     set -g update-environment "DISPLAY SSH_AUTH_SOCK SSH_CONNECTION WINDOWID XAUTHORITY TERM COLORTERM"
     set-environment -g COLORTERM "truecolor"
     
     # Ensure zsh picks up environment and sources .zshrc
     set -g default-command "${pkgs.zsh}/bin/zsh -l -i"
     
     # Automatic window renaming based on hostname and current directory
     set -g automatic-rename on
     set -g automatic-rename-format '#(echo "#{pane_current_command}@$(hostname -s):#{b:pane_current_path}")'
     
     # Alternative: Show just hostname and current directory
     # set -g automatic-rename-format '#(echo "$(hostname -s):#{b:pane_current_path}")'
     
     # Update window title when SSH connection changes
     set -g set-titles on
     set -g set-titles-string '#(echo "$(hostname -s):#{session_name}:#{window_index}:#{pane_current_path}")'
     
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
     set -g mouse on
     set -g set-clipboard on
   '';
    };
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Tmux terminal multiplexer has no hard dependencies";
      }
    ];
  };
}
