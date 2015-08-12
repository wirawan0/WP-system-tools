#!/usr/bin/env python

import sys
from time import localtime, strftime

def parse1(filename):
    """A useful simple tool to read battery charge history 
    in /var/lib/upower/history-* files with meaningful time.
    """
    with open(filename, "r") as F:
        for L in F:
            flds = L.split(None, 1)
            t1 = int(flds[0])
            t2 = flds[1].rstrip()
            t1L = localtime(t1)
            t1L_s = strftime("%c", t1L)
            print("%s %s %s" % (t1, t1L_s, t2))

parse1(sys.argv[1])

