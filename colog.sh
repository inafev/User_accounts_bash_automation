#!/bin/bash
#################################################
# Script para usar ccze en el visionado de logs de manera mas facil y con diferentes
# opciones de utilizacion .
#
# Es necesario tener instalado previamente el programa ccze en el sistema.
#
# Autor: Jesús Arraez Toledo
# Mail : jesus.arraez_at_gmail_dot_com
# Modificado por Iñaki Fernández: www.openerpappliance.com
#
#CCZE log colorizer:
#  • ccze -A < file.log | less -R . (Tip: "man less" to learn how to use less)
#  • grep -i error log_msgs | ccze -A | less -R
#
#COLOG: a ccze wrapper:
#  • Run colog like: "colog -l /var/run/messages.log"
#
#Colog/less commands (same as less commands, "man less" for more info):
#  • "h": Summary of less commands
#  • "-I" : Ignore case
#  • "<" or "SHIFT +G" : Go to End of File
#  • ">" or "p": Go to End of File
#  • "55": Go to line #55
#  • “e /path/file.txt”: edit file
#  • "Right Arrow" and "Left Arrow" for scrolling horizontally
#  • "Mouse wheel" for scrolling vertically
#  • Searching with highlight matches:
#  • "/pattern" : Search forward for (N-th) matching line
#  • "?pattern" : Search backward for (N-th) matching line
#  • "n" : Repeat previous search (for N-th occurrence)
#  • "N" : Repeat previous search in reverse direction
#  • etc.
#
# Poner a [ -x ] en caso de querer debugear
set +x
# Funcion para mostrar el uso del script.
function ayuda() {
#En la siguiente linea sustitir "colog" por el nombre de tu script.
echo -e "\nModo de empleo: colog [OPCION]" [FICHERO]"\n"
echo -e "\t[OPCION]:"
echo ""
echo -e "\t-c
 Muestra todo el contenido directamente.\n"
echo -e "\t-l
 Muestra el contenido filtrado por la orden less.\n"
echo -e "\t-n
 Muestra las ultimas 20 lineas del contenido.\n"
echo -e "\t-f
 Muestra el contenido en tiempo real. Las entradas"
echo -e "\t
 que vayan entrando nuevas en el fichero, se iran"
echo -e "\t
 mostrando en el momento, pulsar Ctrl ^C para"
echo -e "\t
 devolver el prompt.\n"
echo -e "\thelp Muestra esta ayuda.\n"
echo -e "\t[FICHERO] : Ruta absoluta en la que se encuentra el fichero.\n"
exit 0
}
# Funcion error de fichero.
function error_fichero() {
fichero=$1
echo -e "\nNo existe el fichero [\E[1;31m $fichero \E[0;0m] o fichero incorecto.\a\n"
tput sgr0
ayuda
exit 1
}
# Testeo parametro help .
if [ "$1" = --help ]
then
ayuda
exit 0
fi
# Testeo del total de parametros pasados por linea de comandos.
if [ $# != 2 ]
then
#En la siguiente linea sustituir "colog" por el nombre de tu script.
echo -e "\nModo de empleo: colog [OPCION]" [FICHERO]"\n"
echo -e "Usar opcion [ --help ] para mas ayuda.\n"
exit 1
fi
# Ejecucion de opciones pasadas por el usuario.
case $1 in
-c) if [ -f $2 ]
then
ccze -o nolookups -A < $2
else
error_fichero $2
fi ;;
-l) if [ -f $2 ]
then
ccze -o nolookups -A < $2 | less -R
else
error_fichero $2
fi ;;
-n) if [ -f $2 ]
then
tail -n 20 $2 | ccze -A
else
error_fichero $2
fi ;;
-f) if [ -f $2 ]
then
tail -f $2 | ccze -A
else
error_fichero $2
fi ;;
help) ayuda ;;
*) echo -e "Opción [ $1 ] incorrecta."
echo -e "Usar [ --help ] para ayuda de uso\n" ;;
esac
tput sgr0
exit 0
