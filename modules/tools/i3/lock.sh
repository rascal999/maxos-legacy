#!/usr/bin/env bash

# Lock screen with black background
i3lock -c 000000 -n &

# Turn off display
xset dpms force off &

# Create lock screen with clock
DISPLAY_DATE=$(date "+%H:%M")
convert -size 200x100 xc:transparent -font DejaVu-Sans-Bold -pointsize 72 -fill white -gravity center -draw "text 0,0 '$DISPLAY_DATE'" /tmp/lockscreen.png

# Lock screen with the clock image
i3lock -i /tmp/lockscreen.png
