#!/bin/bash
# 20200810
# Polls all the resource usage stats and poll them periodically
# This combines "track-XXX-mem-usage.sh" and "get_usage.sh"
# and polls them periodically.
#

set -e

# We focus on the display :0
: ${XORG_DISPLAY:=":0"}

: ${DUMP_DIR:=dump}
: ${TRACK_PS_XORG:=${DUMP_DIR}/track-Xorg-mem-usage.txt}
: ${VERBOSE:=no}

# VERBOSE is a collection of keywords:
# * yes = All verbosity
# * head = The 30-minute interval usage dump to stdout


check_program () {
    local err=
    which "$1" > /dev/null || err=$?
    if [ "x$err" != x ]; then
        echo "Cannot find program '$1'" >&2
        exit $err
    fi
}

# This one tracks the total memory usage of Xorg
track_usage_1 () {
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

    # -- now skipped, no new info

    # FIXME for grep below--abspath is not the way to go
    # because Xorg may be located somewhere else.
    # We need to exclude earlyoom's arg which includes the word "Xorg"
    # Something better can be done with awk by sequentially scannint
    # the tree-like process list.
    #cat "ps-fuxa-$statkey.txt" | grep '/usr/lib/xorg/Xorg' > "Xorg-usage-$statkey.txt"

    # -- do not dump output to stdout anymore, by default:
    case ":$VERBOSE:" in
        (*:yes:*|*:head:*)
            head *-$statkey.txt
            echo
            ;;
    esac
}


# Check that all prerequisite programs exist:

check_program free
check_program head
check_program ps
check_program xrestop


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

echo "XORG_DISPLAY=$XORG_DISPLAY" >&2
echo "XORG_PID=$XORG_PID" >&2
echo -n "Uptime: "
uptime


main () {
    mkdir -p "$DUMP_DIR"
    (
        STAT_KEY=$(date +"%Y%m%dT%H%M")
        cd "$DUMP_DIR"
        get_usage_complete "$STAT_KEY"
    )

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

    # Explicit "exit" is included here to make the running script
    # not be disrupted if I ever change the script saved on disk.
    # FIXME: can enable this via "-exit" first arg.
    exit
}


# Call the main program and exit:
main "$@"; exit
