#!/bin/bash
# 2020-08-03
#
# Creates a copy of "/proc/$PID/smaps" to analyze memory usage later

#
# Usage: capture-smaps.sh <SMAPS_FILE>
#
# where SMAPS_FILE = /proc/$PID/smaps

TIMESTAMP=$(date +"%s-%Y%m%dT%H%M%S")

case "$1" in
(--pid|-p)
    PROC_PID=$1
    SMAPS_FILE=/proc/$PROC_PID/smaps
    SMAPS_OUT_FILE="smaps-$PID-$TIMESTAMP.txt"
    ;;
(-*)
    echo "Invalid switch: $1" >&2
    exit 1
    ;;
(*)
    SMAPS_FILE="$1"
    SMAPS_OUT_FILE="smaps-$TIMESTAMP.txt"
    ;;
esac

if [ ! -f "$SMAPS_FILE" ]; then
    echo "Error: smaps file does not exist" >&2
    exit 2
fi

cp -p "$SMAPS_FILE" "$SMAPS_OUT_FILE"
