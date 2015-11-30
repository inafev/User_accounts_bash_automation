#!/usr/bin/expect
#$ usage example:
#$ ./passwd.sh username password
if $argc<3 {
  send_user "$argv0: faltan parametros\n"
  send_user "$argv0: uso: $argv0 host username password\n"
  exit
} 

set host [lindex $argv 0]
set username [lindex $argv 1]
set newpass [lindex $argv 2]

spawn ssh -t $host passwd $username
expect "New Password:"
send "$newpass\r"
expect "Re-enter new Password: "
send "$newpass\r"
