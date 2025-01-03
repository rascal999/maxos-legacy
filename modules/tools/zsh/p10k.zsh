# Basic prompt style
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="$ "

# Left prompt segments
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  os_icon                 # os identifier
  dir                     # current directory
  vcs                     # git status
)

# Right prompt segments
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status                  # exit code of the last command
  command_execution_time  # duration of the last command
  background_jobs         # presence of background jobs
)

# Prompt settings
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_TRANSIENT_PROMPT=off
POWERLEVEL9K_INSTANT_PROMPT=quiet

# Directory settings
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"

# VCS settings
POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY=false
POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0.1

# Status colors
POWERLEVEL9K_STATUS_OK=true
POWERLEVEL9K_STATUS_OK_FOREGROUND=2
POWERLEVEL9K_STATUS_ERROR_FOREGROUND=1

# Command execution time
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
