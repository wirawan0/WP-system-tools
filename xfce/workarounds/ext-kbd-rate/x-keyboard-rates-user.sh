#!/bin/sh
# Adapted from http://unix.stackexchange.com/questions/65891/how-to-execute-a-shellscript-when-i-plug-in-a-usb-device
# 20150318
# This script is supposed to run on the user level, not as the
# root.

if [ -n "$DEBUG" ]; then
  set -x
fi

X_USER=${2:-wirawan}
export DISPLAY=${1:-:0}
export XAUTHORITY=${3:-/home/$X_USER/.Xauthority}

is_x_running () {
# Detects whether the X server is up and running on the
# given display
  xdpyinfo > /dev/null 2>&1
}

is_user_session_up () {
# Detects whether the X session of interest is up
  pgrep xfce4-session -u $X_USER  > /dev/null 2>&1
}

get_keyboard_settings () {
  /usr/bin/xfconf-query -c keyboards -p /Default/KeyRepeat/Delay  \
    && /usr/bin/xfconf-query -c keyboards -p /Default/KeyRepeat/Rate 
}

apply_keyboard_settings () {
  if [ $# -eq 2 ]; then
    /usr/bin/xset r rate $1 $2
  else
    return 2
  fi
}

Log () {
  if [ -n "$DEBUG" ]; then
    echo "$*" # >> /tmp/udev_test_action.$X_USER.log
  fi
}

Log "$ACTION :user: $(date)"

if [ "${ACTION}" = "add" ]
then
  sleep 5s
  if is_x_running; then
    if is_user_session_up; then
      KB_SETTINGS=$(get_keyboard_settings) || {
        Log "Error: cannot get keyboard settings"
        exit 1
      }
      apply_keyboard_settings $KB_SETTINGS || {
        Log "Error: cannot apply keyboard settings"
        exit 1
      }
    else
      Log "Warning: target user session is not up; quitting"
    fi
  else
    Log "Warning: X is not running; quitting"
  fi
fi
