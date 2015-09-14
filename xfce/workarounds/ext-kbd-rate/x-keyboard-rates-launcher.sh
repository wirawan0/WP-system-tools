#!/bin/sh
# Adapted from http://unix.stackexchange.com/questions/65891/how-to-execute-a-shellscript-when-i-plug-in-a-usb-device
#

# Set DEBUG to something non-null string if we want to debug the script.
DEBUG=1
X_USER=wirawan
export DISPLAY=:0
export XAUTHORITY="/home/$X_USER/.Xauthority"

Log () {
  if [ -n "$DEBUG" ]; then
    echo "$*" >> /tmp/udev_test_action.log
  fi
}

Log "$ACTION : $(date)"

if [ "${ACTION}" = "add" ]
then
  if [ -n "$DEBUG" ]; then
    export DEBUG
    su -c "/bin/sh /etc/udev/_Actions/x-keyboard-rates-user.sh $DISPLAY $X_USER >> /tmp/udev_test_action.$X_USER.log 2> /tmp/udev_test_action.$X_USER.err" $X_USER &
  else
    su -c "/bin/sh /etc/udev/_Actions/x-keyboard-rates-user.sh $DISPLAY $X_USER > /dev/null 2>&1" $X_USER &
  fi
fi
