#!/bin/bash
#
# smart-start-stop-count.sh
# A SMART utility to check the start-stop count value of the disk
# over time (the Load_Cycle_Count
#
# Created: 20120925
# Wirawan Purwanto
#

while true; do
  date "+%s  %Y-%m-%d %H:%M:%S  " | tr -d '\n'
  smartctl -A /dev/sda | grep Load_Cycle_Count
  sleep 1m
done
