#!/bin/bash 
HOSTSLIST="192.168.122.xxx 192.168.122.xxx"
USER="user1"
PASS="password"
#PASSSU="password"
#CMD=$@
#CMD="sudo su -c id"
CMD="id"
#COMMANDSLIST="whoami "
CMDLIST[1]="whoami"
CMDLIST[2]="id"
CMDLIST[3]="ls -ltr /root"
CMDLIST[4]="ls"
CMDLIST[5]="pwd"


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
spawn ssh -qt -o StrictHostKeyChecking=no $USER@$HOST su -c $CMD
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
#for CMD2 in $COMMANDSLIST
#do
for index in 1 2 3 4 5    # Five lines.
do
#  printf "     %s\n" "${CMDLIST[index]}"
echo The counter2 is $COUNTER2
let COUNTER2=COUNTER2+1 
VAR2=$(expect -c "
spawn ssh -qt -o StrictHostKeyChecking=no $USER@$HOST su -c '${CMDLIST[index]}'
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