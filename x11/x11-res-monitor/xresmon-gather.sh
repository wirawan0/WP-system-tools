#!/bin/bash
#
# Polls all the resource usage stats and save them periodically
# for diagnostics and analysis.
#
# Based on track_resource_stats.sh (not kept here) on my
# Linux system since June 2020.
#
# Last update before incorporation into this toolset:
# -rwxr-xr-x 1 wirawan wirawan 1725 2021-04-10 22:31:45 track_resource_stats.sh
# 33ad3b18c3504bd3254ed7342a0ba047  track_resource_stats.sh
# ceea0860979668e5503f9977f724b7bcd030b848  track_resource_stats.sh



: ${XRESMON_LOGDIR:="dump"}
: ${XRESMON_DISPLAY:=":0"}

: ${XRESMON_MODE:=legacy}

# Adjustable collection timing for "mode1"
: ${XRESMON_MODE1_INTERVAL_BASIC:="1m"}
: ${XRESMON_MODE1_INTERVAL_COMPLETE:="30m"}


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

    cat "ps-fuxa-$statkey.txt" | grep xorg/Xorg > "Xorg-usage-$statkey.txt"

    head *-$statkey.txt
}


# Check "stop" flag: returns zero if a file named "STOP" is found
# in the dump directory:
flagged_stop () {
    test -f "$XRESMON_LOGDIR/stop"
}

XORG_PID=$(
    ps fuxa \
        | awk '/\/usr\/lib\/xorg\/Xorg -core '"$XRESMON_DISPLAY"'/ \
               || /\/usr\/lib\/xorg\/Xorg '"$XRESMON_DISPLAY"'/ {
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

if [ ! -d "$XRESMON_LOGDIR" ]; then
    mkdir -p "$XRESMON_LOGDIR"
fi

TRACK_PS_XORG=${XRESMON_LOGDIR}/track-Xorg-mem-usage.txt


# Legacy loop: All hardwired, designed for very long time
# data collection
# * poll very basic xorg memory usage every minute
# * poll complete usage every minute HH:00 and HH:30
main_loop_legacy () {
    while true; do
        (
            STAT_KEY=$(date +"%Y%m%dT%H%M")
            track_usage_1 "$XORG_PID" >> "$TRACK_PS_XORG"

            case "$STAT_KEY" in
            (*00|*30)
                cd "$XRESMON_LOGDIR"
                get_usage_complete "$STAT_KEY"
                ;;
            esac
            sleep 1m
        )
        if flagged_stop; then
            echo "Exiting main_loop_legacy" >&2
            break
        fi
    done
}


# Smaller loops -- not tied to absolute minute
# but to the beginning of the run time
loop_xorg_basic () {
    local SLEEP_DELAY="${1:-1m}"
    while true; do
        (
            track_usage_1 "$XORG_PID" >> "$TRACK_PS_XORG"
            sleep "$SLEEP_DELAY"
        )
        if flagged_stop; then
            echo "Exiting loop_xorg_basic" >&2
            break
        fi
    done
}

loop_xorg_usage_complete () {
    local SLEEP_DELAY="${1:-30m}"
    while true; do
        (
            STAT_KEY=$(date +"%Y%m%dT%H%M")
            cd "$XRESMON_LOGDIR"
            get_usage_complete "$STAT_KEY"
            sleep "$SLEEP_DELAY"
        )
        if flagged_stop; then
            echo "Exiting loop_xorg_usage_complete" >&2
            break
        fi
    done
}


main_loop_mode1 () {
    loop_xorg_basic "$XRESMON_MODE1_INTERVAL_BASIC" &
    loop_xorg_usage_complete "$XRESMON_MODE1_INTERVAL_COMPLETE" &
    wait
}


main () {
    case "$XRESMON_MODE" in
    (legacy|0)
        main_loop_legacy
        ;;
    (1)
        main_loop_mode1
        ;;
    esac
}

# Call the main function here:
main
