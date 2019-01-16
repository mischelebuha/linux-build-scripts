#!/bin/bash  
#title          :02_del.sh 
#description    :Skript um das Arbeitsverzeichnis zu löschen und neu zu erstellen
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./02_del.sh
#notes          :-
#===========================================================================================

echo ''
echo '--------------------------------------------------------------------------------------'
echo '02_del.sh --> Das Arbeitsverzeichnis wird entfernt ... '
echo '--------------------------------------------------------------------------------------'

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR=${CURRENT_DIR}/workdir

if [ -d $WORK_DIR ]; then
	sudo rm -rf $WORK_DIR
fi

mkdir $WORK_DIR
