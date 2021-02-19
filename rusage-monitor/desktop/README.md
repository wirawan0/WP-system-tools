Tracking resource usage in Linux Desktop
========================================

Tool: track_resource_stats.sh
-----------------------------

Created: approx August 2020

This ad-hoc tool grew out of frustration while I was deploying Ubuntu
20.04 on a laptop computer.
The symptoms include:

* immodest xorg server memory usage, which grew bad over time

* explosion in VLC memory usage

* explosion in Firefox memory usage

* explosion in xorg memory usage *especially* when LibreOffice
  was in use.

This is a very hard problem to track because of
the long-term nature of the issue.
It would take days for the problem to manifest.

This script would produce a snapshot of resource usage using the
following tools:

* ps
* free
* xrestop

In this initial version, the xorg memory usage was tracked every
second, whereas the entire system usage was tracked every 30 minutes.

