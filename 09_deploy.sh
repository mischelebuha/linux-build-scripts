#!/bin/bash  
#title          :09_deploy.sh 
#description    :Skript um die SD-Karte zu erstellen
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./09_deploy.sh 
#notes          :-
#=========================================================================================== 

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR="$CURRENT_DIR/workdir"

SD_ROOTFS=/media/$USER/rootfs
SD_BOOT=/media/$USER/boot

TAR=$CURRENT_DIR/files/tar_buha.sh
UNTAR=$CURRENT_DIR/files/untar_buha.sh


lsblk
read -p 'Welches Block-Device verwenden? : ' BLK
DRIVE=/dev/$BLK

if [ "$DRIVE" = "/dev/sda" ] ; then
	echo "Sorry, not going to format $DRIVE"
	exit 1
fi

format_sd(){
	echo  "Die SD-Karte wird neu formatiert, alle Daten gehen verloren?"
	select SEL in "Ja" "Abbrechen"; do
		case $SEL in
			"Ja") break;;
			"Abbrechen") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done

	if [ "$SEL" = "Ja" ] ; then
		echo -e "\nWorking on $DRIVE\n"

		#make sure that the SD card isn't mounted before we start
		if [ -b ${DRIVE}1 ]; then
			sudo umount ${DRIVE}1
			sudo umount ${DRIVE}2
		elif [ -b ${DRIVE}p1 ]; then
			sudo umount ${DRIVE}p1
			sudo umount ${DRIVE}p2
		else
			sudo umount $DRIVE
		fi

		# Partitionstabelle löschen
		sudo dd if=/dev/zero of=$DRIVE bs=1024 count=1024


		SIZE=`sudo fdisk -l $DRIVE | grep Disk | awk '{print $5}'`

		echo DISK SIZE - $SIZE bytes

		CYLINDERS=`echo $SIZE/255/63/512 | bc`

		sudo sfdisk -D -H 255 -S 63 -C $CYLINDERS $DRIVE << EOF
,9,0x0C,*
10,,,-
EOF
	

		echo "Formatting FAT partition on $DRIVE"
		sudo mkfs.vfat -F 32 ${DRIVE}1 -n "boot"
	
		echo "Formatting $DEV as ext4"
		sudo mkfs.ext4 -q -L "rootfs" ${DRIVE}2

		echo "Für weiteres Vorgehen sicherstellen das die Partitionen gemountet wurden."
		echo "Doppelklick auf CF's oder SD entfernen und wieder verbinden"
	fi
}

cp_boot(){
echo  "MLO und U-Boot auf die SD-Karte kopieren?"
	select SEL in "Ja" "Abbrechen"; do
		case $SEL in
			"Ja") break;;
			"Abbrechen") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done

	if [ "$SEL" = "Ja" ] ; then
		SOURCE_PATH=`find $WORK_DIR/deploy -maxdepth 1 -type f -name "boot_*" | xargs ls | tail -1`
		sudo rm -rf $SD_BOOT/*
		echo "syncing..."; sync
	
		echo "$SOURCE_PATH -->  $SD_BOOT"
		$UNTAR $SOURCE_PATH $SD_BOOT
		echo "syncing..."; sync
	fi
}

cp_sysroot(){
echo  "Sysroot auf die SD-Karte kopieren?"
	select SEL in "Ja" "Abbrechen"; do
		case $SEL in
			"Ja") break;;
			"Abbrechen") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done

	if [ "$SEL" = "Ja" ] ; then
		SOURCE_PATH=`sudo find $WORK_DIR/deploy -maxdepth 1 -type f -name "sysroot_*" | xargs ls | tail -1`
		sudo rm -rf $SD_ROOTFS/*
		echo "syncing..."; sync
		$UNTAR $SOURCE_PATH $SD_ROOTFS
		echo "syncing..."; sync
	fi
}

cp_rootfs(){
	echo  "Das RootFS auf die SD-Karte kopieren?"
	select SEL in "Ja" "Abbrechen"; do
		case $SEL in
			"Ja") break;;
			"Abbrechen") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done

	if [ "$SEL" = "Ja" ] ; then
		SOURCE_PATH=`find $WORK_DIR/deploy -maxdepth 1 -type f -name "rootfs_*" | xargs ls | tail -1`
		sudo rm -rf $SD_ROOTFS/*
		echo "syncing..."; sync
		$UNTAR $SOURCE_PATH $SD_ROOTFS
		echo "syncing..."; sync
	fi
}

cp_kernel(){
	echo  "Kernel, DTB, uEnv.txt, Modules, Firmware und die SGX-Treiber auf die SD-Karte kopieren?"
	select SEL in "Ja" "Abbrechen"; do
		case $SEL in
			"Ja") break;;
			"Abbrechen") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done

	if [ "$SEL" = "Ja" ] ; then
		# Kernel, uEnv.txt, DTB, modules, firmware und SGX-Treiber enptacken
		$UNTAR `find $WORK_DIR/deploy -maxdepth 1 -type f -name "kernel_*" | xargs ls | tail -1` $SD_ROOTFS
		echo "syncing..."; sync
	fi
}

cp_qt_lib(){
	echo  "Qt-Libs auf die SD-Karte kopieren?"
	select SEL in "Ja" "Abbrechen"; do
		case $SEL in
			"Ja") break;;
			"Abbrechen") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done

	if [ "$SEL" = "Ja" ] ; then
		SOURCE_PATH=`find $WORK_DIR/deploy -maxdepth 1 -type f -name "Qt*" | xargs ls | tail -1`
		DESTINATION_PATH=$SD_ROOTFS/opt/qt5
		sudo mkdir -p $DESTINATION_PATH
		$CURRENT_DIR/files/untar_buha.sh $SOURCE_PATH $DESTINATION_PATH
		echo /opt/qt5/lib | sudo tee $SD_ROOTFS/etc/ld.so.conf.d/qt5.conf
		echo "syncing..."; sync
		echo ""
		echo "Nach dem Start Qt-Libs hinzufügen: sudo ldconfig"
	fi
}

cp_bsp_apk(){
	echo  "Application und Startscript auf die SD-Karte kopieren?"
	select SEL in "Ja" "Abbrechen"; do
		case $SEL in
			"Ja") break;;
			"Abbrechen") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done

	if [ "$SEL" = "Ja" ] ; then
		sudo cp -v $CURRENT_DIR/files/start_demo.sh $SD_ROOTFS/home/debian/
		sudo cp -v $CURRENT_DIR/files/SlideMenu $SD_ROOTFS/home/debian/
		sudo chmod +x $SD_ROOTFS/home/debian/*
		sudo cp -v $CURRENT_DIR/files/set_env $SD_ROOTFS/home/debian/
		sudo chown $USER:$USER $SD_ROOTFS/home/debian/*
		sudo cp -v $CURRENT_DIR/files/README $SD_ROOTFS/home/debian/
		sudo cp -v $CURRENT_DIR/files/00-touchscreen.rules $SD_ROOTFS/etc/udev/rules.d/
		sudo cp -v $CURRENT_DIR/files/start_demo.service $SD_ROOTFS/lib/systemd/system/
		echo "syncing..."; sync
	fi
}

gen_sysroot(){
	echo ''
	echo "Builddep. von Qt5 installieren (Qt Multimedia, QtWebview, QtWebengine) https://wiki.qt.io/Building_Qt_5_from_Git"
	echo "- sudo apt-get update && sudo apt-get -y upgrade"
	echo "- sudo apt-get -y install build-essential libssl-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libfontconfig1-dev libasound2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev flex bison gperf libicu-dev libxslt-dev ruby libssl-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libfontconfig1-dev"
	echo "Grafiktreiber installieren:"
	echo "- sudo /opt/gfxinstall/sgx-install.sh"
	echo ""
	echo  "SYSROOT auf den PC-Kopieren? (Alles installiert?)"
	select SEL in "Ja" "Abbrechen"; do
		case $SEL in
			"Ja") break;;
			"Abbrechen") break;;
			*) echo "Bitte richtige Zahl eingeben!";;
		esac
	done

	if [ "$SEL" = "Ja" ] ; then
		DESTINATION_PATH=$WORK_DIR/deploy/sysroot_`date +%Y-%m-%d_%H-%M`.tar.gz
		
		$TAR $SD_ROOTFS $DESTINATION_PATH
		sudo chown $USER $DESTINATION_PATH
		echo "syncing..."; sync
	fi
}




while :
do
    cat<<EOF
================================================================
    Deploy to SD
---------------------------------------------------------------
    Gewünschter Vorgang auswählen:

    (1) SD formatieren
    (2) MLO, U-Boot  --> SD
    (3) RooFS        --> SD
    (4) Kernel       --> SD
    (5) Sysroot      <-- SD
    (6) Sysroot      --> SD
    (7) Qt-Libraries --> SD
    (8) Application  --> SD
    (q) Quit
---------------------------------------------------------------
EOF
    read -p "Bitte Nummer eingeben:"
	echo ""
    case "$REPLY" in
    "1")  format_sd ;;
    "2")  cp_boot ;;
    "3")  cp_rootfs ;;
    "4")  cp_kernel ;;
    "5")  gen_sysroot ;;
    "6")  cp_sysroot ;;
    "7")  cp_qt_lib ;;
    "8")  cp_bsp_apk ;;
	"q")  exit ;;
     * )  echo "Falsche Eingabe..."     ;;
    esac
done


