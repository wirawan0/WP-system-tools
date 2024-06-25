#!/bin/sh
#
# mtime-iso8601.sh
# Reads in a file's mtime stamp and express it
# in the ISO-8601 format:
#     YYYY-mm-dd"T"HH:MM:SS TZ
#
# Some use cases:
# - to store the mtime ad-hoc in git log message


set -eu

: ${FILENAME:=${1:?Error: Arg 1 must contain a file name}}

if [ ! -f "$FILENAME" ]; then
    echo "Error: file does not exist: $FILENAME"
fi

date +"%Y-%m-%dT%H:%M:%S %z" -r "$FILENAME"
