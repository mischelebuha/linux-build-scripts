#!/bin/bash  
#title          :10_qtcreator.sh 
#description    :Skript um den Qt-Creator zu installieren oder zu starten
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./10_qtcreator.sh 
#notes          :-
#=========================================================================================== 

echo ''
echo '--------------------------------------------------------------------------------------'
echo 'qtcreator --> Der Qt-Creator wird installiert oder gestartet ...'
echo '--------------------------------------------------------------------------------------'

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR=${CURRENT_DIR}/workdir
QTCREATOR_DIR=${WORK_DIR}/qtcreator

QTCREATOR_PATH=http://download.qt.io/official_releases/qtcreator/3.6/3.6.0/
QTCREATOR_FILE=qt-creator-opensource-linux-x86_64-3.6.0.run
QT_MKSPEC_DIR=${WORK_DIR}/qt/Qt-5.5.1/mkspecs


cd  $WORK_DIR

SEL="Qt-Creator neu installieren"
if [ -d $QTCREATOR_DIR ]; then
	echo "Wähle eine Option?"
		select SEL in "Qt-Creator starten" "Qt-Creator neu installieren"; do
		case $SEL in
			"Qt-Creator starten") break;;
			"Qt-Creator neu installieren") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done
fi

if [ "$SEL" = "Qt-Creator starten" ] ; then
	export QMAKESPEC=${QT_MKSPEC_DIR}/linux-oe-g++
	export MKSPEC=${QT_MKSPEC_DIR}/linux-linaro-gnueabihf-g++
	${QTCREATOR_DIR}/qtcreator/bin/qtcreator &
fi

if [ "$SEL" = "Qt-Creator neu installieren" ] ; then
	if [ -d $QTCREATOR_DIR ]; then
        sudo rm -rf $QTCREATOR_DIR    
	fi

	mkdir $QTCREATOR_DIR
	cd $QTCREATOR_DIR

	wget ${QTCREATOR_PATH}/${QTCREATOR_FILE}
	sudo chmod +x ${QTCREATOR_FILE}

    echo ""
	echo "Den Qt-Creator in folgendem Verzeichnis installieren: $QTCREATOR_DIR/qtcreator"
	echo ""

	./${QTCREATOR_FILE}
fi


cd $CURRENT_DIR
