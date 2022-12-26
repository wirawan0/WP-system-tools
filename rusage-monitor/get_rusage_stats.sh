#!/bin/bash

if [ -z "$1" ]; then
    statkey=$(date +"%Y%m%dT%H%M")
else
    statkey=${1:?Need a stat key (date8 + letter)}
fi

if [ -f "free-$statkey.txt" ]; then
    echo "Refuse to overwrite existing stat."
    exit 1
fi

free > "free-$statkey.txt"

xrestop -b -m 1 > "xrestop-$statkey.txt"

ps fuxa > "ps-fuxa-$statkey.txt"

cat "ps-fuxa-$statkey.txt" | grep Xorg > "Xorg-usage-$statkey.txt"

head *-$statkey.txt
