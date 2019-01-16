#!/bin/bash
#title          :01_start.sh
#description    :Menü für das Buildtool
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.0   
#usage          :./01_start.sh
#notes          :Hier soll ein Menü entstehen um die Skripte 02_ - XX_ aufzurufen
#===========================================================================================

$APPS=

sudo apt-get install $APPS

select SEL in "a , b, c"; do
	case $SEL in
		a ) echo "test"; break;;
		b )  echo "test"; break;;
		c )  echo "test"; exit;;
		*) echo "Bitte richtige Zahl eingeben!";;
	esac
done


