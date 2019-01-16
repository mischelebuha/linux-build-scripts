#!/bin/bash  
#title          :08_qt5.sh 
#description    :Skript um Qt5 zu erstellen
#author         :Michael Schnaitter
#date           :2016-03-08
#version        :0.1    
#usage          :./08_qt5.sh 
#notes          :Es werden zusätzlich zum Open-Source einige Enterprise-Features compiliert.
#===========================================================================================

echo '--------------------------------------------------------------------------------------'
echo 'qt.sh --> Qt wir herruntergeladen und compiliert ...'
echo '--------------------------------------------------------------------------------------'

CURRENT_DIR2="$( cd "$( dirname "$0" )" && pwd )"
WORK_DIR="${CURRENT_DIR2}/workdir"
cd $WORK_DIR

mkdir qt
cd qt

CURRENT_DIR=`pwd`

CC_PRE="${WORK_DIR}/armcc/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/bin/arm-linux-gnueabihf-"

QT_SRCDIR="${CURRENT_DIR}/qt-everywhere-opensource-src-5.5.1"
QT_SRCFILE="${QT_SRCDIR}.tar.gz"
QT_URL="https://download.qt.io/official_releases/qt/5.5/5.5.1/single/qt-everywhere-opensource-src-5.5.1.tar.gz"

PREFIX_NAME="Qt-5.5.1"
PREFIX="${CURRENT_DIR}/${PREFIX_NAME}"
ROOTFS_DIR="${WORK_DIR}/sysroot"
LOG_DIR="${CURRENT_DIR}/logfiles"
NPROC=`nproc`
CONFIGURE_ARGS="-opensource -confirm-license -release\
				-prefix /opt/qt5 -extprefix ${PREFIX} \
				-device linux-beaglebone-g++ \
				-device-option CROSS_COMPILE=${CC_PRE}
				-sysroot ${ROOTFS_DIR} \
				-silent -v\
			    -no-xcb -opengl es2 \
				-nomake tests\
				"
# 				-nomake examples
###############################################################
#clean up
# delete old log files
if [ -d ${LOG_DIR} ]; then
        sudo rm -rf ${LOG_DIR}
        mkdir ${LOG_DIR}
fi

# create the logfiles folder
if [ ! -d ${LOG_DIR} ]; then
        mkdir ${LOG_DIR}
fi

# delete qt src folder (old build stuff in it)
if [ -d ${QT_SRCDIR} ]; then
        sudo rm -rf ${QT_SRCDIR}
fi

# delete qt prefix folder (old build stuff in it)
if [ -d ${PREFIX} ]; then
        sudo rm -rf ${PREFIX}
fi

# download qt source
if [ ! -f ${QT_SRCFILE} ]; then
	wget ${QT_URL}
fi

# extract qt source
if [ ! -d ${QT_SRCDIR} ]; then
	$CURRENT_DIR2/files/untar_buha.sh ${QT_SRCFILE} ${CURRENT_DIR} 
	sudo chown -R ${USER}:${USER} ${QT_SRCDIR} 
fi



###############################################################
# extract the rootfs if it's missing
if [ ! -d ${ROOTFS_DIR} ]; then
        mkdir ${ROOTFS_DIR}
        sudo tar xf ${CURRENT_DIR}/rootfs.tar.bz2 -C ${ROOTFS_DIR}
fi

###############################################################
# copy script to create relative symlinks of the libs with absolute symlinks in the rootfs...
if [ ! -f ${CURRENT_DIR}/fixQualifiedLibraryPaths ]; then
    cp  ${CURRENT_DIR2}/files/fixQualifiedLibraryPaths ${CURRENT_DIR}
	chmod +x fixQualifiedLibraryPaths
fi

# ...fix the symlinks
sudo ./fixQualifiedLibraryPaths ${ROOTFS_DIR} ${CC_PRE}g++

###############################################################
# create device...
cd ${QT_SRCDIR}/qtbase/mkspecs/devices/
cp -rv linux-beagleboard-g++ linux-beaglebone-g++
sed 's/softfp/hard/' <linux-beagleboard-g++/qmake.conf >linux-beaglebone-g++/qmake.conf


###############################################################
# configure qt
cd ${QT_SRCDIR}
if [ ! -d ${PREFIX} ]; then
	./configure  $CONFIGURE_ARGS 2>&1 | tee -a ${LOG_DIR}/qt-configure-log.txt
	###############################################################
	# build qt
	make -j$NPROC 2>&1 | tee -a ${LOG_DIR}/qtbase-build-log.txt
	sudo make install	
fi

# user our fresh compiled cross-qmake
QMAKE_CROSS="${PREFIX}/bin/qmake"


PACK_ARRAY=( qt-charts-enterprise qtdatavisualization-enterprise qtquick2drenderer-enterprise qtquickcontrols-enterprise qtvirtualkeyboard-enterprise qtvirtualkeyboard-enterprise)
for PKG_NAME in "${PACK_ARRAY[@]}"
do
	tar xf ${CURRENT_DIR2}/files/${PKG_NAME}* -C $QT_SRCDIR
	cd $QT_SRCDIR/${PKG_NAME}*
	${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/${PKG_NAME}-qmake-log.txt
	sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/${PKG_NAME}-make-log.txt
	sudo make install
done


$CURRENT_DIR2/files/tar_buha.sh ${CURRENT_DIR}/${PREFIX_NAME} ${WORK_DIR}/deploy/${PREFIX_NAME}_`date +%Y-%m-%d_%H-%M`.tar.gz

cd $CURRENT_DIR2
