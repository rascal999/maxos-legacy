# Basics
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
POWERLEVEL9K_DISABLE_INSTANT_PROMPT=true

# Classic style
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir                     # current directory
  vcs                     # git status
  newline
  prompt_char            # prompt symbol
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

# Disable icons and use ASCII
typeset -g POWERLEVEL9K_MODE=ascii

# Simple directory display
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=40
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=false

# Simple VCS display
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

# Basic prompt character
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='$'

# No background colors
typeset -g POWERLEVEL9K_BACKGROUND=none
