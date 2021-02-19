#!/bin/bash
# 20200810
# Polls all the resource usage stats and poll them periodically
# This combines "track-XXX-mem-usage.sh" and "get_usage.sh"
# and polls them periodically.

set -e

DUMP_DIR=dump
TRACK_PS_XORG=${DUMP_DIR}/track-Xorg-mem-usage.txt

# This one tracks the total memory usage of Xorg
track_usage_1() {
    local TRACK_PID="$1"
    local D U
    D=$(date  +"%Y-%m-%d %H:%M:%S")
    # /usr/lib/xorg/Xorg -core :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch
    #awk '$2 == TRACK_PID { printf("%s  %9d %9d\n", D, $5, $6) }' D="$D" TRACK_PID="$TRACK_PID" "$PS_FILE"
    echo -n "$D  "
    ps uh -p "$TRACK_PID"
}

# This one does more complete usage dump
get_usage_complete () {
    statkey=${1:?Need a stat key (date8 + letter)}

    if [ -f "free-$statkey.txt" ]; then
        echo "Refuse to overwrite existing stat."
        exit 1
    fi

    free > "free-$statkey.txt"

    xrestop -b -m 1 > "xrestop-$statkey.txt"

    ps fuxa > "ps-fuxa-$statkey.txt"

    cat "ps-fuxa-$statkey.txt" | grep Xorg > "Xorg-usage-$statkey.txt"

    head *-$statkey.txt
}


XORG_PID=$(
    ps fuxa \
        | awk '/\/usr\/lib\/xorg\/Xorg -core :0/ {
                   success = 1
                   print($2) # print the PID
                   exit
               }
               END {
                   exit(!success)
               }'
)
echo "XORG_PID=$XORG_PID" >&2

#exit 

mkdir -p "$DUMP_DIR"
while true; do
    (
        STAT_KEY=$(date +"%Y%m%dT%H%M")
        track_usage_1 "$XORG_PID" >> "$TRACK_PS_XORG"

        case "$STAT_KEY" in
        (*00|*30)
            cd "$DUMP_DIR"
            get_usage_complete "$STAT_KEY"
            ;;
        esac
        sleep 1m
    )
done
