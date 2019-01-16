#!/bin/bash  
#title          :07_sysroot.sh 
#description    :Skript nach der Installation von Abhängikeiten ein sysroot zu erstellen
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./07_sysroot.sh 
#notes          :Es wird das Skript 09_deploy.sh benutzt. Dort muss selbstständig Punkt 1-5
#                ausgeführt werden.
#===========================================================================================

echo ''
echo '--------------------------------------------------------------------------------------------------'
echo 'sysroot.sh --> Es wird eine SD-Karte erstellt um die Abhängikeiten für Qt zu installieren ... '
echo '--------------------------------------------------------------------------------------------------'

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR="${CURRENT_DIR}/workdir"
SYSROOT_DIR=${WORK_DIR}/sysroot

TAR=$CURRENT_DIR/files/tar_buha.sh
UNTAR=$CURRENT_DIR/files/untar_buha.sh


TEMP_VAR="j"
if [ -d $SYSROOT_DIR ]; then
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		read -p 'SYSROOT wurde schon erstellt, löschen und neu erstellen? [j/n] : ' TEMP_VAR
		echo ""
		echo " "
		ENTERCORRECTLY=1
		case $TEMP_VAR in
		"j") ;;
		"n") ;;
		*)  echo "Bitte j or n";ENTERCORRECTLY=0;;
		esac
	done
fi

if [ "$TEMP_VAR" = "j" ] ; then

	if [ -d $SYSROOT_DIR ]; then
        sudo rm -rf $SYSROOT_DIR
	fi
	echo "######### Option 1-5 ausführen... ##########"
	./09_deploy.sh
	
	
	mkdir -p $SYSROOT_DIR
	SOURCE_PATH=`find ${WORK_DIR}/deploy -maxdepth 1 -type f -name "sysroot_*" | xargs ls | tail -1`
	$UNTAR $SOURCE_PATH $SYSROOT_DIR
	
fi













