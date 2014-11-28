#!/bin/sh
#
# shred-free-space.sh
# A simple utility to "shred" the disk free space so that the
# pre-existing contents are not recognizable.
#
# Created: 20141128
# Wirawan Purwanto
#

set -e

optVerbose=yes
optShredTimes=1


create_dummy_file() {
  DUMMY_FILE=$(mktemp shredfree_XXXXXXXX)
  if [ "x$optVerbose" = xyes ]; then
    echo "create_dummy_file: Filename = $DUMMY_FILE"
  fi
  dd if=/dev/zero of="$DUMMY_FILE" bs=4096 || true
  if [ "x$optVerbose" = xyes ]; then
    echo "create_dummy_file: Result: $(ls -l $DUMMY_FILE)"
  fi
}

shred_dummy_file() {
  local verb
  if [ "x$optVerbose" = xyes ]; then
    verb=-v
  else
    verb=
  fi
  shred $verb -n "$optShredTimes" -z "$DUMMY_FILE"
}

main() {
  create_dummy_file
  shred_dummy_file
}

main

