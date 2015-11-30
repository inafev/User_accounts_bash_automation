#!/bin/bash 
HOSTSLIST="host1 host2 host3 host4 host5 host6 host7 host8 host9 host10"
USER="user1"
PASS="password1"
#PASSSU="password"
#CMD=$@
##################################
# LINUX:
##################################
SUCMD="su -c"
CMD="id"
CMDLIST[1]="userdel -r user2"
CMDLIST[2]="useradd -u 13473 -g 100 -c "userA" -d /export/home/userA -m -s /bin/bash userA"
CMDLIST[3]="useradd -u 16109 -g 100 -c "userB" -d /export/home/userB -m -s /bin/bash userB"
CMDLIST[4]="useradd -u 10371 -g 100 -c "userC" -d /export/home/userC -m -s /bin/bash userC"
CMDLIST[5]="id"
##################################
# SOLARIS:
##################################
#SUCMD='su root -c'
#CMD='id'
#CMDLIST[1]='userdel -r user2'
#CMDLIST[2]='useradd -u 13473 -g 100 -c "userA" -d /export/home/userA -m -s /bin/bash userA'
#CMDLIST[3]='useradd -u 16109 -g 100 -c "userB" -d /export/home/userB -m -s /bin/bash userB'
#CMDLIST[4]='useradd -u 10371 -g 100 -c "userC" -d /export/home/userC -m -s /bin/bash userC'
#CMDLIST[5]='id'
# NEWPASSWD:
CMDLIST2[1]='passwd userA'
CMDLIST2[2]='passwd userB'
CMDLIST2[3]='passwd userC'
NEWPASSWORD[1]='passA'
NEWPASSWORD[2]='passB'
NEWPASSWORD[3]='passC'


# Indico el LANG, porque si el cliente está en LANG=es_ES, el resultado es "contraseña incorrecta"
LANG=C
COUNTER=1

if [ -f hosts-sin-clave.output ];
then
rm hosts-sin-clave.output
fi

if [ -f resultado-CMDLIST.log ];
then
rm resultado-CMDLIST.log
fi

echo -n "Desea ejecutar NEWPASSWD COMMANDS? (y/n):" 
read newpasswdexec

for HOST in $HOSTSLIST
do
echo "HOST ES $HOST"
echo
echo The counter is $COUNTER
let COUNTER=COUNTER+1 
echo

for innerloop in 1 2 3 4 5
  do
    echo -n "Iteracion #$innerloop"
    echo
    read -sp "Enter your remote root password :" PASSU
    echo
    #echo "mi clave es $PASSU"

VAR=$(expect -c "
spawn ssh -qt -o StrictHostKeyChecking=no $USER@$HOST $SUCMD$CMD
match_max 100000
expect \"*?assword:*\"
send -- \"$PASS\r\"
expect \"*?assword:*\"
send -- \"$PASSU\r\"
send -- \"\r\"
expect eof
")
echo "++++++++++++++++++++++++++"
echo $VAR
echo "++++++++++++++++++++++++++"

echo "$VAR" > resultado-CMD.log
LOGINSUCCESS=`awk '/incorrect password/ {print $0}' resultado-CMD.log`
if [ -z "$LOGINSUCCESS" ]; # Si password es correcto
then
COUNTER2=1
for index in 1 2 3 4 5    # Five lines.
do
#  printf "     %s\n" "${CMDLIST[index]}"
echo The counter2 is $COUNTER2
let COUNTER2=COUNTER2+1 
VAR2=$(expect -c "
spawn ssh -qt -o StrictHostKeyChecking=no $USER@$HOST $SUCMD '${CMDLIST[index]}'
match_max 100000
expect \"*?assword:*\"
send -- \"$PASS\r\"
expect \"*?assword:*\"
send -- \"$PASSU\r\"
send -- \"\r\"
expect eof
")
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>"
echo $VAR2
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "$VAR2" >> resultado-CMDLIST.log
done
###########################################
# NEWPASSWD COMMANDS
###########################################
if [ $newpasswdexec == "y" ];
then
for index2 in 1 2 3   # 3 lines.
do
VAR3=$(expect -c "
spawn ssh -qt -o StrictHostKeyChecking=no $USER@$HOST $SUCMD '${CMDLIST2[index2]}'
match_max 100000
expect \"*?assword:*\"
send -- \"$PASS\r\"
expect \"*?assword:*\"
send -- \"$PASSU\r\"
expect \"*?assword:*\"
send -- \"${NEWPASSWORD[index2]}\r\"
expect \"*?assword:*\"
send -- \"${NEWPASSWORD[index2]}\r\"
expect eof
")
echo "**************************"
echo $VAR3
echo "**************************"
echo "$VAR3" >> resultado-CMDLIST.log
done
fi
# Salgo del loop de 5 intentos porque he dado con la clave correcta
break
fi
done

LOGINFAILS=`awk '/incorrect password/ {print $0}' resultado-CMD.log`
if [ -n "$LOGINFAILS" ]; # Si password es incorrecto tras los N intentos -> no lo conozco
then
echo "$HOST" >> hosts-sin-clave.output
#echo "loginfails es $LOGINFAILS"
fi
done

#Notas:
#ssh "-q"      Quiet mode.  Causes most warning and diagnostic messages to be suppressed.
