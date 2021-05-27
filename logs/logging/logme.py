#!/usr/bin/env python3
#
# Created: 20210512

"""
logme.py - Simple command logging utility

Usage: logme.py COMMAND [ARG1 [ARG2 ...]]

This command itself does not take command-line argument.
Settings to this program will be fed via environment variables.
Use script to wrap your local settings.
"""

import json
import os
import socket
import subprocess
import sys
import time

# PyYAML
import yaml

"""
TODO:

* configuration file (YAML-based?) to determine logging level, etc.
"""

if "IN_IPYTHON" not in globals():
    IN_IPYTHON = "get_ipython" in globals()

HOME = os.environ['HOME']
HOSTNAME = socket.gethostname()

# MUST be an absolute path
LOG_FILE = os.path.join(HOME, '.local', 'logme-default.log')


def logme_run(cmd):
    """Main subprogram to run a command and log it.
    A log entry in YAML format will be saved in the text file
    (name specified in the global variable LOG_FILE).

    Args:
        cmd (list): command to execute, to include the program
            as arg 0, followed by optional arguments.

    Returns:
        dict: Log record.
    """
    pwd = os.getcwd()
    date_str = time.strftime("%Y-%m-%dT%H:%M:%S")
    # Log the command first
    log_rec = dict(
        cwd=pwd,
        command=list(cmd),
        timestamp=date_str,
        host=HOSTNAME,
    )
    log_str = yaml.dump([log_rec])
    with open(LOG_FILE, "a") as LF:
        LF.write(log_str)
    ret_code = subprocess.call(cmd, shell=False)
    log_rec['ret_code'] = ret_code

    # FIXME: This is a terrible hack to add the return code
    # after the fact!
    with open(LOG_FILE, "a") as LF:
        LF.write("  ret_code: {:d}\n".format(ret_code))

    return log_rec


def help():
    print(__doc__.strip())


if (__name__ == "__main__") and not IN_IPYTHON:
    if len(sys.argv) < 2:
        help()
        sys.exit(1)
    elif sys.argv[1] in ('-h', '--help'):
        help()
        sys.exit(0)

    rslt = logme_run(sys.argv[1:])
    sys.exit(rslt['ret_code'])
