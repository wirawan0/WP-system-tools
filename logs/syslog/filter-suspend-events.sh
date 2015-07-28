#!/bin/bash


function Cat()
# Outputs a text file whether compressed or not
{
  case "$1" in
  (*.bz2)
    bzip2 -d < "$1"
    ;;
  (*.gz|*.Z)
    gzip -d < "$1"
    ;;
  (*.lzma)
    lzma -d < "$1"
    ;;
  (*.xz)
    xz -d < "$1"
    ;;
  (*)
    cat "$1"
    ;;
  esac
}

function Cat_files()
{
  local F
  for F in "$@"; do
    Cat "$F"
  done
}

function filter_suspend1()
{
  gawk '
  BEGIN {
    state = "start"
  }

  function print_line()
  {
    if (show_line_no)
    {
      printf "%6d %s\n", FNR, $0
    }
    else
    {
      print
    }
  }

  # On sleep...
  /NetworkManager.*<info> sleep requested/ {
    if (state != "start")
      print ""
    print_line()
    state = "NM_SLEEP_REQUEST"
  }
  /PM: Syncing filesystem/ {
    print_line()
    state = "PM_SLEEP_PREP_SYNC"
  }

  /PM: Preparing system for mem sleep/ {
    print_line()
    state = "PM_SLEEP_PREP"
  }

  # On resume...
  /ACPI: Low-level resume complete/ {
    print_line()
    state = "ACPI_RESUMED"
  }
  /PM: resume of devices complete/ {
    print_line()
    state = "PM_RESUMED"
  }
  /NetworkManager.*<info> wake requested/ {
    print_line()
    state = "NM_WAKE_REQUEST"
  }

  /ntpd.*: peers refreshed/ {
    state_old = state
    state = "NTPD_REFRESHED"
    if (state_old != state)
      print_line()
  }
  ' show_line_no=1 "$@"
}

if [ $# -eq 0 ]; then
  filter_suspend1 /var/log/syslog
else
  for FILE in "$@"; do
    echo "$FILE:"
    Cat "$FILE" | filter_suspend1
  done
fi
