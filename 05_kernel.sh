#!/bin/bash  
#title          :05_kernel.sh 
#description    :Skript um das den Kernel einzurichten
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./05_kernel.sh 
#notes          :Die fertigen Dateinen landen in dem DEPLOY_DIR. Es wurde hier auf den
#                Kernel von RobertCNelson zurückgegriffen. Da hier auch Skripts zum 
#                Erstellen der SGX-Treiber vorhanden sind.
#                Beim Problemen beim erstellen der .tar.gz Files gegebenenfalls kernel_version anpassen
#===========================================================================================

echo ''
echo '--------------------------------------------------------------------------------------'
echo 'kernel.sh --> Der Kernel wird herruntergeladen und compiliert ...'
echo '--------------------------------------------------------------------------------------'

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR=${CURRENT_DIR}/workdir
KERNEL_DIR=${WORK_DIR}/kernel
KERNEL_DEPLOY_DIR=${KERNEL_DIR}/deploy
KERNEL_DEPLOY_TEMP_DIR=${KERNEL_DEPLOY_DIR}/temp

TAR=$CURRENT_DIR/files/tar_buha.sh
UNTAR=$CURRENT_DIR/files/untar_buha.sh

KERNEL_GIT_PATH=https://github.com/RobertCNelson/bb-kernel
KERNEL_GIT_BRANCH=origin/am33x-v4.4
kernel_version='4.4.4-bone5'

KERNEL_PATCH_DIR=${KERNEL_DIR}/patches/met

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

	git clone $KERNEL_GIT_PATH $KERNEL_DIR
	cd $KERNEL_DIR
	git checkout $KERNEL_GIT_BRANCH -b tmp
	
	# Kernel-Patches kopieren nur < 4.4
	#mkdir $KERNEL_PATCH_DIR
	#cp ${CURRENT_DIR}/files/Input_Touchscreen_FT6236.patch ${KERNEL_PATCH_DIR}

	# Kernel und Module bauen
	./build_kernel.sh
	
	# Met Device Tree Kompilieren
	cd $KERNEL_DIR/KERNEL
	cp ${CURRENT_DIR}/files/am335x-boneblack-met32bit.dts arch/arm/boot/dts/am335x-boneblack-met.dts
	make ARCH=arm CROSS_COMPILE=../dl/gcc-*/bin/arm-linux-gnueabihf- am335x-boneblack-met.dtb
	
	cd $KERNEL_DIR
	# SGX-Grafiktreiber bauen
	./sgx_build_modules.sh

	# Kernel, uEnv.txt, DTB, modules, firmware und SGX-Treiber packen
	mkdir -p $KERNEL_DEPLOY_TEMP_DIR/boot $KERNEL_DEPLOY_TEMP_DIR/usr/include
	sudo cp -v ${WORK_DIR}/kernel/deploy/${kernel_version}.zImage $KERNEL_DEPLOY_TEMP_DIR/boot/vmlinuz-${kernel_version}
	sudo sh -c "echo 'uname_r=${kernel_version}' >> $KERNEL_DEPLOY_TEMP_DIR/boot/uEnv.txt"
	sudo cp -v ${WORK_DIR}/kernel/KERNEL/arch/arm/boot/dts/am335x-boneblack-met.dtb $KERNEL_DEPLOY_TEMP_DIR/boot/am335x-boneblack.dtb
	$UNTAR ${WORK_DIR}/kernel/deploy/${kernel_version}-modules.tar.gz $KERNEL_DEPLOY_TEMP_DIR
	$UNTAR ${WORK_DIR}/kernel/deploy/${kernel_version}-firmware.tar.gz $KERNEL_DEPLOY_TEMP_DIR/lib/firmware
	$UNTAR ${WORK_DIR}/kernel/deploy/GFX_5.01.01.02_es8.x.tar.gz $KERNEL_DEPLOY_TEMP_DIR
	sudo cp -r -v /home/buha/02_bbb/04_Build_Scripts/workdir/kernel/ignore/SDK_BIN/Graphics_SDK_setuplinux_5_01_01_02/GFX_Linux_SDK/OGLES2/SDKPackage/Builds/OGLES2/Include/* $KERNEL_DEPLOY_TEMP_DIR/usr/include
	$TAR $KERNEL_DEPLOY_TEMP_DIR $KERNEL_DEPLOY_DIR/${kernel_version}-kernel_modules_firmware_sgx_dts_uEnv.tar.gz
	sudo rm -r $KERNEL_DEPLOY_TEMP_DIR

	# Alles nach deploy kopieren
	mkdir ${WORK_DIR}/deploy
	cp -v ${KERNEL_DEPLOY_DIR}/${kernel_version}-kernel_modules_firmware_sgx_dts_uEnv.tar.gz ${WORK_DIR}/deploy/kernel_`date +%Y-%m-%d_%H-%M`_${kernel_version}_robercnelson.tar.gz
	sudo chown $USER ${WORK_DIR}/deploy/kernel_*
fi


cd $CURRENT_DIR
