# Classic prompt style
POWERLEVEL9K_MODE='compatible'
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="$ "

# Left prompt segments
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir                     # current directory
  vcs                     # git status
)

# Right prompt segments
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status                  # exit code of the last command
  time                    # current time
)

# Prompt settings
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_INSTANT_PROMPT=off

# Directory settings
POWERLEVEL9K_DIR_PATH_SEPARATOR="/"
POWERLEVEL9K_HOME_FOLDER_ABBREVIATION="~"
POWERLEVEL9K_DIR_PATH_ABSOLUTE=false

# Status colors
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='red'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='white'

# Time format
POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
