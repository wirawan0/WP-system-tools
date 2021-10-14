#!/bin/bash
# 2020-08-03
#
# Creates a copy of "/proc/$PID/smaps" to analyze memory usage later

#
# Usage: capture-smaps.sh <SMAPS_FILE>
#
# where SMAPS_FILE = /proc/$PID/smaps

TIMESTAMP=$(date +"%s-%Y%m%dT%H%M%S")

SMAPS_FILE="$1"
if [ ! -f "$SMAPS_FILE" ]; then
    echo "Error: smaps file does not exist" >&2
    exit 2
fi

cp -p "$SMAPS_FILE" "smaps-$TIMESTAMP.txt"
