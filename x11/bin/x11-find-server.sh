#!/bin/bash

# We focus on the display :0
: ${XORG_DISPLAY:=":0"}

# An AWK program to find the PID of the particular X server:
PRG_FIND_XORG='
    $11 ~ /\/Xorg/ {
        # scan only the args of this program:
        for (iarg = 12; iarg <= NF; ++iarg)
        {
            if ($iarg == XORG_DISPLAY)
            {
                success = 1
                print($2) # print the PID
                exit
            }
        }
    }

    END {
        exit(!success)
    }
'

XORG_PID=$(
    ps aux \
        | awk -v XORG_DISPLAY="$XORG_DISPLAY" "$PRG_FIND_XORG"
)
err=$?

echo "XORG_DISPLAY=$XORG_DISPLAY"
echo "XORG_PID=$XORG_PID"

exit $err
