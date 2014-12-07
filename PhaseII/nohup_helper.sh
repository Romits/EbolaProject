#!/bin/sh -e
################################################
# Simple wrapper to send nohup logs to a file
################################################

TIMESTAMP="$(date +'%Y%m%d.%H%M%S')-$$"
set -x
LOGFILE="simulation-$TIMESTAMP.log"
nohup $* > "$LOGFILE" 2>&1 &
