#!/bin/bash  
#title          :06_rootfs.sh 
#description    :Skript um das RootFS zu erstellen
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./06_rootfs.sh 
#notes          :Hier wurde auf ein fertiges Debian RootFS, welches mit dem Omap-Image-Builder
#                von RobertCNelson generiert wurde, zurückgegegriffen.
#===========================================================================================
echo ''

echo '--------------------------------------------------------------------------------------'
echo 'rootfs.sh --> Das Root-File-System wird herruntergeladen und entpackt ...'
echo '--------------------------------------------------------------------------------------'

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR=${CURRENT_DIR}/workdir
ROOTFS_DIR=${WORK_DIR}/rootfs

TAR=$CURRENT_DIR/files/tar_buha.sh
UNTAR=$CURRENT_DIR/files/untar_buha.sh
ROOTFS_PATH=https://rcn-ee.com/rootfs/eewiki/minfs/
ROOTFS_FILE=debian-8.3-minimal-armhf-2016-01-25
ROOTFS_EXT=.tar.xz
ROOTFS_TEMP_DIR=${ROOTFS_DIR}/rootfs_temp
ROOTFS_TEMP_ARCHIVE=${ROOTFS_TEMP_DIR}.tar.gz


cd $WORK_DIR

TEMP_VAR="j"
if [ -d $ROOTFS_DIR ]; then
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		read -p 'Das RootFS wurde schon erstellt, löschen und neu erstellen? [j/n] : ' TEMP_VAR
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

	if [ -d $ROOTFS_DIR ]; then
        sudo rm -rf $ROOTFS_DIR
	fi

	mkdir $ROOTFS_DIR
	
    cd $ROOTFS_DIR

	wget -c ${ROOTFS_PATH}${ROOTFS_FILE}${ROOTFS_EXT}
	echo "Entpacke: ${ROOTFS_FILE}${ROOTFS_EXT} --> $ROOTFS_DIR ..."
	tar xf ${ROOTFS_FILE}${ROOTFS_EXT} -C $ROOTFS_DIR

	mkdir $ROOTFS_TEMP_DIR

	# RootFS entpacken
	echo "Entpacke: ${ROOTFS_FILE}/armhf-rootfs-debian-jessie.tar --> $ROOTFS_TEMP_DIR ..."
	sudo tar xf ${ROOTFS_FILE}/armhf-rootfs-debian-jessie.tar -C $ROOTFS_TEMP_DIR

	# fstab Eintrag damit FS R/W, /etc/network/interfaces -> DHCP
	sudo sh -c "echo '/dev/mmcblk0p1  /  auto  errors=remount-ro  0  1' >> $ROOTFS_TEMP_DIR/etc/fstab"
	sudo cp -v ${CURRENT_DIR}/files/interfaces $ROOTFS_TEMP_DIR/etc/network/


	# RootFS packen und komprimieren, Ordner löschen
	$TAR  $ROOTFS_TEMP_DIR ${WORK_DIR}/deploy/rootfs_`date +%Y-%m-%d_%H-%M`_${kernel_version}.tar.gz
	sudo chown $USER ${WORK_DIR}/deploy/rootfs_*
	sudo rm -r $ROOTFS_TEMP_DIR
fi

cd $CURRENT_DIR
