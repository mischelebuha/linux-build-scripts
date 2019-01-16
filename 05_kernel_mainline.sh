#!/bin/bash  
#title          :05_kernel_mainline.sh 
#description    :Skript um das den Mainline-Kernel einzurichten
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./05_kernel_mainline.sh 
#notes          :!!! Script ist noch nicht lauffähigt da noch keine kernelkonfig erstellt wurde!!!
#===========================================================================================

echo ''
echo '--------------------------------------------------------------------------------------'
echo 'kernel.sh --> Der Kernel wird herruntergeladen und compiliert ...'
echo '--------------------------------------------------------------------------------------'

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR=${CURRENT_DIR}/workdir
KERNEL_DIR=${WORK_DIR}/kernel_mainline
KERNEL_DEPLOY_DIR=${KERNEL_DIR}/deploy
KERNEL_DEPLOY_TEMP_DIR=${KERNEL_DEPLOY_DIR}/temp

TAR=$CURRENT_DIR/files/tar_buha.sh
UNTAR=$CURRENT_DIR/files/untar_buha.sh


KERNEL_VERSION="4.4"
KERNEL_PATH=https://cdn.kernel.org/pub/linux/kernel/v4.x/
KERNEL_FILE=linux-4.4
KERNEL_EXT=.tar.xz
KERNEL_MAKE_CONFIG=bbb_defconfig
KERNEL_MAKE='zImage modules am335x-boneblack-met.dtb'
CORES=$(getconf _NPROCESSORS_ONLN)


cd $WORK_DIR

TEMP_VAR="j"
if [ -d $KERNEL_DIR ]; then
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		read -p 'Der Kernel wurde schon erstellt, löschen und neu erstellen? [j/n] : ' TEMP_VAR
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

	if [ -d $KERNEL_DIR ]; then
        sudo rm -rf $KERNEL_DIR  
	fi

	mkdir $KERNEL_DIR
	cd $KERNEL_DIR

	# Kernel herrunterladen und entpacken
	wget -c ${KERNEL_PATH}${KERNEL_FILE}${KERNEL_EXT}
	tar xJf ${KERNEL_FILE}${KERNEL_EXT}
	KERNEL_SRC_DIR=${KERNEL_DIR}/${KERNEL_FILE}
	cd ${KERNEL_SRC_DIR}

	# Met Device Tree kopieren
	cp ${CURRENT_DIR}/files/am335x-boneblack-met.dts ${KERNEL_SRC_DIR}/arch/arm/boot/dts/

	# Kernel defconfig kopieren
	cp ${CURRENT_DIR}/files/bbb_defconfig ${KERNEL_SRC_DIR}/arch/arm/configs/
	
	# Kernel, Module, DeviceTree kompilieren
	make ARCH=arm CROSS_COMPILE=${CC} distclean
    make ARCH=arm CROSS_COMPILE=${CC} $KERNEL_MAKE_CONFIG
	make ARCH=arm CROSS_COMPILE=${CC} menuconfig 
    make ARCH=arm CROSS_COMPILE=${CC} $KERNEL_MAKE -j${CORES}

	mkdir $KERNEL_DEPLOY_DIR
	
	# Module packen
    mkdir $KERNEL_DEPLOY_TEMP_DIR/boot
	make ARCH=arm CROSS_COMPILE=${CC} modules_install $KERNEL_DEPLOY_TEMP_DIR
	make ARCH=arm CROSS_COMPILE=${CC} firmware_install $KERNEL_DEPLOY_TEMP_DIR
	cp -v ${KERNEL_SRC_DIR}/arch/arm/boot/zImage $KERNEL_DEPLOY_TEMP_DIR/boot/vmlinuz-${kernel_version}
	sh -c "echo 'uname_r=${KERNEL_VERSION}' >> $KERNEL_DEPLOY_TEMP_DIR/boot/uEnv.txt"
	cp -v ${KERNEL_SRC_DIR}/arch/arm/boot/dts/am335x-boneblack-met.dtb $KERNEL_DEPLOY_TEMP_DIR/boot/am335x-boneblack.dtb
	$TAR $KERNEL_DEPLOY_TEMP_DIR ${WORK_DIR}/deploy/kernel_`date +%Y-%m-%d_%H-%M`_${kernel_version}_mainline.tar.gz
	rm -r $KERNEL_DEPLOY_TEMP_DIR

	mkdir -p $KERNEL_DEPLOY_TEMP_DIR
	$UNTAR $KERNEL_DEPLOY_DIR/${KERNEL_VERSION}-kernel_dtb_uEnv.tar.gz $KERNEL_DEPLOY_TEMP_DIR 
fi


cd $CURRENT_DIR
