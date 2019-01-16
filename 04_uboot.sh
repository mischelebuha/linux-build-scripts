#!/bin/bash  
#title          :04_uboot.sh 
#description    :Skript um das U-Boot einzurichten
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./04_uboot.sh 
#notes          :Die fertigen Dateinen landen in dem DEPLOY_DIR
#===========================================================================================

echo ''
echo '--------------------------------------------------------------------------------------'
echo 'uboot.sh --> U-Boot wurd herruntergeladen und gepatcht und kompiliert ... '
echo '--------------------------------------------------------------------------------------'

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR=${CURRENT_DIR}/workdir
UBOOT_DIR=${WORK_DIR}/uboot
DEPLOY_DIR=${WORK_DIR}/deploy

UBOOT_PATH=ftp://ftp.denx.de/pub/u-boot/
UBOOT_FILE=u-boot-2016.01
UBOOT_EXT=.tar.bz2
UBOOT_MAKE_CONFIG=am335x_evm_defconfig

UBOOT_PATCH_PATH=https://rcn-ee.com/repos/git/u-boot-patches/v2016.01/
UBOOT_PATCH_FILE=0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch

cd $WORK_DIR

. ./armcc/config-armcc

TEMP_VAR="j"
if [ -d $UBOOT_DIR ]; then
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		read -p 'U-Boot wurde schon erstellt, löschen und neu erstellen? [j/n] : ' TEMP_VAR
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

	if [ -d $UBOOT_DIR ]; then
        rm -rf $UBOOT_DIR
        
	fi
	
	mkdir $UBOOT_DIR
	cd $UBOOT_DIR

	# U-Boot herunterladen
	wget -c ${UBOOT_PATH}${UBOOT_FILE}${UBOOT_EXT}
	tar xf ${UBOOT_FILE}${UBOOT_EXT}

	cd u-boot-*

	# U-Boot patchen
	wget ${UBOOT_PATCH_PATH}${UBOOT_PATCH_FILE}
	patch -p1 < ${UBOOT_PATCH_FILE}

	# Uboot Kompilieren
	make ARCH=arm CROSS_COMPILE=${CC} distclean
	make ARCH=arm CROSS_COMPILE=${CC} $UBOOT_MAKE_CONFIG
	make ARCH=arm CROSS_COMPILE=${CC} -j5

	# MLO und U-Boot packen, komprimieren
	mkdir -p ${DEPLOY_DIR}
	tar czfv ${DEPLOY_DIR}/boot_`date +%Y-%m-%d_%H-%M`.tar.gz MLO u-boot.img
	chown $USER ${DEPLOY_DIR}/boot_*.tar.gz
fi

cd $CURRENT_DIR
