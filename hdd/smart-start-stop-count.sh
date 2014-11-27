#!/bin/bash
#
# smart-start-stop-count.sh
# A SMART-based utility to check the load/unload (start/stop) cycle value
# of a disk over time (the Load_Cycle_Count parameter).
#
# NOTE: Requires root privilege to run the smartctl command.
#
# Created: 20120925
# Wirawan Purwanto
#

: ${DEVICE:=/dev/sda}
: ${DELAY:=1m}

while true; do
  date "+%s  %Y-%m-%d %H:%M:%S  " | tr -d '\n'
  smartctl -A "$DEVICE" | grep Load_Cycle_Count
  sleep "$DELAY"
done
