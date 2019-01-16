#!/bin/bash  
#title          :tar.sh 
#description    :Skript um .tar.gz Dateien zu entpacken (mit Root-Rechten)
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./untar_buha.sh <absolute_path_to_archive>.tar.gz <absolute_path>
#notes          :-
#============================================================================       
#!/bin/bash

untar_progress ()
{
	SRC_PATH=$1
	DEST_PATH=$2
	echo "Entpacke: $SRC_PATH --> $DEST_PATH ..."
	pv $SRC_PATH | sudo tar zxf - -C $DEST_PATH
}

untar_progress $1 $2
