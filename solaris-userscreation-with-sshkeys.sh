#!/bin/bash 
while read host
do
#echo -e "SOLARIS SERVER: $host\n"
#ssh $host /bin/sh <<\EOF
#userdel -r phe6544
#useradd -u 13473 -g 100 -c "UserA" -d /export/home/userA -m -s /bin/bash userA
#useradd -u 16109 -g 100 -c "UserB" -d /export/home/userB -m -s /bin/bash userB
#useradd -u 10371 -g 100 -c "UserC" -d /export/home/userC -m -s /bin/bash userC
#EOF
##ssh -t bender passwd passA
##ssh -t bender passwd passB
##ssh -t bender passwd passC

./passwdremoto.sh $host userA passwordA
./passwdremoto.sh $host userB passwordB
./passwdremoto.sh $host userC passwordC
done < solaris-prod-hosts.txt
