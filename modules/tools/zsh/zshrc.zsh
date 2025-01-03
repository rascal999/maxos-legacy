# Source p10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Ensure p10k theme is loaded
[[ -f /run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme ]] && \
  source /run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

export MCFLY_KEY_SCHEME=vim
export MCFLY_RESULTS=40
export MCFLY_RESULTS_SORT=LAST_RUN

bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# Shell aliases
alias ll="ls -l"
alias update="sudo nixos-rebuild switch"
alias dig="grc dig"
alias id="grc id"
alias ps="grc ps"
alias lg="lazygit"
alias ff="firefox"
alias ls="grc ls"

# Basic zsh options
setopt EXTENDED_HISTORY       # Write the history file in the ':start:elapsed;command' format.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.

# Initialize mcfly if available
if command -v mcfly &> /dev/null; then
  eval "$(mcfly init zsh)"
fi
