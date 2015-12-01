# User accounts bash automation, November-December 2009
Automation of non-centralized user accounts management with shell scripting. Inventory and colog.sh scripts

- colog.sh : A ccze wrapper that colors your logs
- inventory-script.sh : simple shell script that automatically collects data from a list of linux hosts, creating an inventory file in CSV format.
- Purpose of remaining scripts is the automated user accounts management with tools like 'expect', 'ssh keys' (after issuing passphrase) and SSH remote commands execution. Avoid running remote commands with root privileges when possible. Use ssh-keys with a passphrase as a replacement of password based logins, getting rid of 'expect' based solutions.
- Security policy: Do NOT use the same 5-10 passwords for gaining root access to a large number of servers! This is quite common and also why SSH keys with a passphrase should be used instead. Otherwise simple and automated scripts like the following could gain access to your whole infrastructure without access control (i.e. in a large list of servers by logging in as a non root user and trying a list of N passwords for gaining root access, where any code/command could be remotely execute with full privileges).
