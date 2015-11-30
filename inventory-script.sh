#!/bin/bash -x 
# how to redirect standard error and output from a shell script to a file:
# ./inventory-script.sh 2>>output.txt > inventory.csv

while read myhost
do
ALL_HOSTS="${ALL_HOSTS} $myhost"
done < list-of-hosts.txt # 1 host per line


echo "HOSTNAME","FQDN","IP","OPERATING SYSTEM","RELEASE","DETAILED RELEASE","CPU","CPU SPEED","PROCESSORS","CORES","KERNEL","MEMORY in MB","SWAP in MB","LOAD AVERAGE","UPTIME","SYSTAT","DATE","MDSTAT RAID SW","FILE SYSTEM USAGE","HTTPD","TOMCAT","JDK TOMCAT","TOMCAT APPS","JAVA JBOSS","JBOSS","HYPERIC","ACTIONAL","MYSQL"

LANG=C
COUNTER=1 

#if [ -f output.txt ];
#then
#rm output.txt
#fi

for HOST in ${ALL_HOSTS};
do 
echo "==========================================================================" >> output.txt 2>&1
echo "HOST ES $HOST" >> output.txt 2>&1
echo "==========================================================================" >> output.txt 2>&1
#echo
#echo The counter is $COUNTER
#let COUNTER=COUNTER+1 
#echo

ssh user1@$HOST /bin/bash <<\EOF  

# HOSTNAME
VARHOSTNAME=`hostname -s`

# HOSTNAME FQDN
VARHOSTNAMEFQDN=`hostname`

# OPERATING SYSTEM
VAROS=`uname -o`

# KERNEL
VARKERNEL=$(uname -r)
 
# SHORT RELEASE
VARSHORTRELEASE=""
echo $VARKERNEL >> tmp.out 2>&1 | grep "2.6.9" && VARSHORTRELEASE="RHEL4" 
echo $VARKERNEL >> tmp.out 2>&1 | grep "2.6.9" || VARSHORTRELEASE="RHEL5" 
echo $VARKERNEL >> tmp.out 2>&1 | grep "2.4" && VARSHORTRELEASE="RHEL3" 

# DETAILED RELEASE
VARRELEASE=`grep -v redhat-release /etc/redhat-release | grep release | awk '/release/ {print $0}' | head -n1 | sed 's/\/\\m//i' | sed 's/\/\\m//i'`
if [ -z "$VARRELEASE" ]; # no he econtrado la release, pruebo con VMWARE
then
VARRELEASE=`grep -i vmware /etc/redhat-release | awk '/vmware/i {print $0}' | head -n1 | sed 's/\/\\m//i' | sed 's/\/\\m//i'`
fi

# CPU MODEL
VARCPU=`uname -p`

# CPU SPEED
VARCPUSPEED1=$(egrep 'GHz|MHz' /proc/cpuinfo)
VARCPUSPEED2=$(expr "$VARCPUSPEED1" : ".* \([0-9]*\.[0-9]*[G|M]Hz\).*")
VARCPUSPEED3=$(expr "$VARCPUSPEED1" : ".*MHz.*: \([0-9]*\.[0-9]*\).*")
if [ "$VARCPUSPEED2" != "" ];
then
VARCPUSPEED="$VARCPUSPEED2"
else
VARCPUSPEED="$VARCPUSPEED3"
fi

# NUMBER OF PROCESSORS
VARPROCNUMBER=$(grep "^physical id" /proc/cpuinfo | awk '{print $NF}' | uniq | wc -l)
VARCORENUMBER=`grep processor /proc/cpuinfo | wc -l`

# UPTIME
VARUPTIME=$(uptime | awk -F "up" '{ print $2 }' | awk -F "," '{ print $1 }')

# last 15 min load average
# uptime | awk '{print "1min:"$(NF-2)" 5min:"$(NF-1)" 15min:"$NF}' | tr -s ',' ' '
#VARLAST15MINLOADAVERAGE=$(uptime | awk -F "load average:" '{ print $2 }' | cut -d, -f3)
#VARLAST15MINLOADAVERAGE=$(uptime | awk '{print $NF}')
VARLOADAVERAGE=$(uptime | awk '{print "1min:"$(NF-2)" 5min:"$(NF-1)" 15min:"$NF}' | tr -s ',' ' ')

# SYSSTAT (iostat,mpstat,sar)
VARSYSSTAT=$(rpm -qa | grep -i sysstat)

# DATE
VARDATE=$(date)

# MDSTAT, RAID SOFTWARE
VARMDSTAT=$(cat /proc/mdstat | grep md)

# FILE SYSTEM USAGE
#VARFILESYSTEMUSAGE=$(df -P -h | sort -g -k 5 | awk '$5 ~ /%/ {print $5,$6}' | sed 1d)
VARFILESYSTEMUSAGE=$(df -P -h | sort -g -k 5 | awk '{print $1,$2,$(NF-1),$NF}' | sed 's/\/dev\/mapper\///g' | sed 1d)
# MEMORY
VARMEMORY=$(free -m | awk '/Mem/{print $2}')

# SWAP
VARSWAP=$(free -m | awk '/Swap/{print $2}')

# IPs
#VARIPS=`/sbin/ifconfig  | egrep 'inet |inet:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | tr -s '\n' ' '`
VARIPS=`/sbin/ifconfig  | egrep 'inet |inet:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

# HTTPD
VARHTTPD1=`/usr/sbin/httpd -version`
VARHTTPD2=`echo $VARHTTPD1 | tr -s '\n' ' '`
VARHTTPD=`expr "$VARHTTPD2" : ".*Apache/\([^ ]*\).*"`

# TOMCAT
#VAR3=`find /software /apps -name catalina.sh | xargs -I {} -t bash {} version`
#VAR4=`echo $VAR3 | tr -s '\n' ' '`
#VARTOMCAT=`expr "$VAR4" : ".*Tomcat/\([^Server]*\).*"
find /software/ /apps -type f -name catalina.out > inakioutput1.txt
ALL_FILES=""
while read myfile 
do
ALL_FILES="${ALL_FILES} $myfile"
done < inakioutput1.txt

for FILE in ${ALL_FILES};
do
VAR3=`grep -i "Apache Tomcat/" -m1 ${FILE}`
VAR4=`expr "$VAR3" : ".*Tomcat/\([0-9].[0-9].[0-9]*\).*"`
VARTOMCAT="$VARTOMCAT$VAR4"$'\n' 
done

# JAVA / JDK DEL TOMCAT
VARTOMCATJDK1=`ps uaxww | grep -i tomcat` 
VARTOMCATJDK=`expr "$VARTOMCATJDK1" : ".*jdk\([^/]*\).*"`

# APLICACIONES DEL TOMCAT

find /software /apps -name server.xml -type f -exec grep -li "appBase=" {} \; > inakioutput1.txt
ALL_FILES=""
while read myfile 
do
ALL_FILES="${ALL_FILES} $myfile"
done < inakioutput1.txt

VARTOMCATAPPS=""
for FILE in ${ALL_FILES};
do
VARTOMCATAPPS1=$(grep -i "appBase=" -m1 ${FILE})
VARTOMCATAPPS2=$(expr "$VARTOMCATAPPS1" : ".*appBase=\"\(.*\)/deploy.*")
VARTOMCATAPPS="$VARTOMCATAPPS$VARTOMCATAPPS2"$'\n' 
done

# JAVA DEL JBOSS
VARJBOSSJAVA1=`ps uaxww | grep -i jboss` 
VARJBOSSJAVA2=`expr "$VARJBOSSJAVA1" : ".*/java\([^/]*\)/bin.*"`
VARJBOSSJAVA3=`expr "$VARJBOSSJAVA1" : ".*jdk\([^/]*\).*"`
if [ "$VARJBOSSJAVA2" != "" ];
then
VARJBOSSJAVA="$VARJBOSSJAVA2"
else
VARJBOSSJAVA="$VARJBOSSJAVA3"
fi
# HYPERIC
VARHYPERIC1=`ps uaxww | grep -i hyperic`
VARHYPERIC=`expr "$VARHYPERIC1" : ".*hyperic-hq-agent-\([^/]*\).*"`

# JBOSS
VARJBOSS1=""
VARJBOSS1=`find /software /apps -name boot.log -type f -exec grep -li "Release ID: JBoss" {} \; | xargs grep -i "Release"` 
VARJBOSS=`expr "$VARJBOSS1" : ".*JBoss \([^(]*\).*"`

# ACTIONAL
VARACTIONAL1=`find /software /apps -name product.info -type f -exec grep -li "Actional Agent" {} \; | xargs grep -vi "logicalversion" | grep -vi "MajorVersion" | grep -vi "MinorVersion"`
VARACTIONAL2=`echo $VARACTIONAL1 | tr -s '\n' ' '`
VARACTIONAL=`expr "$VARACTIONAL2" : ".*Version: \([^ ]*\).*"`

# MYSQL
VARMYSQL1=`rpm -q mysql`
VARMYSQL=`expr "$VARMYSQL1" : ".*mysql-\([^\n]*\).*"`

echo \"$VARHOSTNAME\",\"$VARHOSTNAMEFQDN\",\""${VARIPS}"\",\"$VAROS\",\"$VARSHORTRELEASE\",\"$VARRELEASE\",\"$VARCPU\",\"$VARCPUSPEED\",\"$VARPROCNUMBER\",\"$VARCORENUMBER\",\""${VARKERNEL}"\",\"$VARMEMORY\",\"$VARSWAP\",\"$VARLOADAVERAGE\",\"$VARUPTIME\",\"$VARSYSSTAT\",\"$VARDATE\",\""${VARMDSTAT}"\",\""${VARFILESYSTEMUSAGE}"\",\"$VARHTTPD\",\""${VARTOMCAT}"\",\"$VARTOMCATJDK\",\""${VARTOMCATAPPS}"\",\"$VARJBOSSJAVA\",\"$VARJBOSS\",\"$VARHYPERIC\",\"$VARACTIONAL\",\"$VARMYSQL\"

EOF

done
