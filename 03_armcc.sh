#!/bin/bash  
#title          :03_armcc.sh 
#description    :Skript um den Cross-Compiler einzurichten
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./03_armcc.sh 
#notes          : Es wurde die Version 4.8-2014.04 benutzt da Qt bei neueren
#                 Versionen Problem gemacht hat
#===========================================================================================

echo ''
echo '--------------------------------------------------------------------------------------'
echo 'armcc.sh --> Cross-Compiler wird heruntergeladen und enpackt ... '
echo '--------------------------------------------------------------------------------------'

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR=${CURRENT_DIR}/workdir
GCC_DIR=${WORK_DIR}/armcc

GCC_PATH=https://releases.linaro.org/14.04/components/toolchain/binaries/
GCC_FILE=gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux
GCC_EXT=.tar.xz

cd $WORK_DIR
mkdir $GCC_DIR
cd $GCC_DIR

# Cross-Compiler downloaden
wget -c ${GCC_PATH}${GCC_FILE}${GCC_EXT}
tar xf ${GCC_FILE}${GCC_EXT}

# Datei mit Pfad zum Crooss-Compiler anlegen
echo "export CC=`pwd`/${GCC_FILE}/bin/arm-linux-gnueabihf-" > config-armcc


cd $CURRENT_DIR
