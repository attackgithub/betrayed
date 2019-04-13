#!/bin/bash
[ $(id -u) != 0 ] && exit
usage(){ echo "$0 irc.host \"#channel\""; exit; }
[ -z "$1" ] && usage
[ -z "$2" ] && usage
HOST="$1" CHANNEL="$2" bash install.sh
