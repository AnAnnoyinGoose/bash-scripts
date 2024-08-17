#!/bin/bash
TOUCHSCREEN='FTSC1000:00 2808:1015'
XDISPLAY=`xrandr --current | grep primary | sed -e 's/ .*//g'`
xrandr --output $XDISPLAY --rotate right
TRANSFORM='Coordinate Transformation Matrix'
[ ! -z "$TOUCHSCREEN" ] && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM" 0 1 0 -1 0 1 0 0 1
