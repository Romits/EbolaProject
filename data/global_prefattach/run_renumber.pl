#!/bin/sh -xe
COMMANDS_LIST=commands.list
time parallel -j 6 -t --eta --halt-on-error 2 -a $COMMANDS_LIST
