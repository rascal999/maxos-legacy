# Debug logging for shell initialization
echo "Starting zsh initialization..." >&2

# Source p10k config
if [[ -f ~/.p10k.zsh ]]; then
  echo "Sourcing p10k config..." >&2
  source ~/.p10k.zsh
else
  echo "p10k config not found!" >&2
fi

# Ensure p10k theme is loaded
if [[ -f /run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme ]]; then
  echo "Re-sourcing p10k theme..." >&2
  source /run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
else
  echo "p10k theme not found in zshrc!" >&2
fi

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

# History settings
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"

# Create history directory if it doesn't exist
[[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zsh" ]] || mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

# Basic zsh options
setopt EXTENDED_HISTORY       # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS     # Do not display a previously found event.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.

# Initialize mcfly if available
if command -v mcfly &> /dev/null; then
  eval "$(mcfly init zsh)"
fi
