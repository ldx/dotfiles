#!/bin/sh

CURBR="$(xrandr --current --verbose|grep 'Brightness:'|head -1|awk '{print $2}')"
STEP="0.05"
MAXBR="1.0"
MINBR="0"
echo "current brightness" $CURBR

case "$1" in
    U|u|[U,u]p)
        # increase brightness by 5%
        _brightness=$(echo $CURBR+$STEP|bc)
        echo "desired new brightness" $_brightness
        _res=$(echo "$_brightness <= $MAXBR"|bc)
        if [ "$_res" -eq 1 ]; then
            echo "new brightness" $_brightness
            xrandr --output eDP-1 --brightness $_brightness
        fi
        ;;
    D|d|[D,d]own|[D,d]o)
        # increase brightness by 5%
        _brightness=$(echo $CURBR-$STEP|bc)
        echo "desired new brightness" $_brightness
        _res=$(echo "$_brightness >= $MINBR"|bc)
        if [ "$_res" -eq 1 ]; then
            echo "new brightness" $_brightness
            xrandr --output eDP-1 --brightness $_brightness
        fi
        ;;
    *)
        echo "Usage: $0 [up|down]"
        exit 1
        ;;
esac

exit 0
