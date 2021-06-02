
The script pair is written to mitigate issues that xfce did not set up
keyboard delay & rate correctly for a plugged external keyboard.


`x-keyboard-rates-launcher.sh`: udev-triggerred script (run as root) that
is launched upon plugging in an external keyboard to the computer.
This should be installed in /etc/udev/rules.d/  (?)

`x-keyboard-rates-user.sh`: user-level script to re-set (override)
the keyboard rates manually.
The keyboard delay & repeat rate are read from XFCE configuration database
to prevent hardcoded values.
