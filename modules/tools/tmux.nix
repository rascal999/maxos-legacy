{ config, pkgs, lib, ... }: {
  # tmux
  programs.tmux = {
    enable = true;
    historyLimit = 100000;

    extraConfig = ''
      bind "e" send-keys "exit" \; send-keys "Enter"
      bind "Enter" send-keys "exa --long --all --header --icons --git" \; send-keys "Enter"
      bind "l" send-keys "duf" \; send-keys "Enter"
      bind "r" send-keys "uname -a" \; send-keys "Enter"
      bind "Space" send-keys "exa --long --all --header --icons --git --sort=modified" \; send-keys "Enter"
      bind "Tab" send-keys "ls -alh" \; send-keys "Enter"
      bind "u" send-keys "dust ." \; send-keys "Enter"

      unbind C-b
      unbind [

      set -g prefix C-Space
      set -g mode-keys vi'';

    # Ensure required tools are available
    packages = with pkgs; [
      exa
      duf
      dust
    ];
  };
}
