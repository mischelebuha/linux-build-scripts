#!/bin/bash  
#title          :tar.sh 
#description    :Skript um .tar.gz Dateien zu packen (mit Root-Rechten)
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./tar_buha.sh <absolute_path> <absolute_path_to_archive>.tar.gz
#notes          :-
#============================================================================       

tar_progress()
{
	SRC_PATH=$1
	DEST_PATH=$2
	OLD_PATH=`pwd`
	echo "Packe: $SRC_PATH -->  $DEST_PATH ..."
	cd $SRC_PATH
	sudo tar cpf - . | pv -s $(sudo du -sb . | cut -f1) | gzip > $DEST_PATH
	cd $OLD_PATH
}

tar_progress $1 $2
