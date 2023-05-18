#!/bin/bash

## @file
## @author Jens Tirsvad Nielsen
## @brief Linux Iso incl Preseed.cfg
## @details
## **Build linux iso incl preseed.cfg**
## Requires:
##	- 'xorriso' installed
##	  sudo apt install xorriso
##	- preseed.cfg
##	  1) Look at example http://www.debian.org/releases/stretch/example-preseed.txt
##	  2) Read manual https://www.debian.org/releases/stable/i386/apb.html
##	  3) Install manually and then export preseed answers:
##	     sudo apt-get install debconf-utils
##	     debconf-get-selections --installer >> preseed.cfg
## This script downloads Debians's iso and makes it auto-install
##

#####[ MD5 Fix func ]#####
fixSum() {
  local _FILE
  local _PLACE
  local _MD5_LINE_BEFORE
  local _MD5_BEFORE
  local _MD5_LINE_AFTER

	_FILE=$1
	_PLACE=$2

	_MD5_LINE_BEFORE=$( grep "$_PLACE" md5sum.txt)
	_MD5_BEFORE=$( echo "$_MD5_LINE_BEFORE" | awk '{ print $1 }' )
	_MD5_AFTER=$( md5sum "$_FILE" | awk '{ print $1 }' )
	_MD5_LINE_AFTER=$( echo "$_MD5_LINE_BEFORE" | sed -e "s#$_MD5_BEFORE#$_MD5_AFTER#" )
	sed -i -e "s#$_MD5_LINE_BEFORE#$_MD5_LINE_AFTER#" md5sum.txt
}

TCLI_LINUXISOWITHPRESEED_FILE_ISO=$( wget -qO - ${TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL}/SHA512SUMS | grep netinst | grep -v mac | head -n 1 | awk '{ print $2 }' )

if [ ! -f "$TCLI_LINUXISOWITHPRESEED_FILE_ISO" ]; then
	wget "${TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL}/${TCLI_LINUXISOWITHPRESEED_FILE_ISO}" -O "${TCLI_LINUXISOWITHPRESEED_PATH_ISO}/${TCLI_LINUXISOWITHPRESEED_FILE_ISO}"
fi

#####[ Working directory ]#####
TCLI_LINUXISOWITHPRESEED_WORKDIR=temp
rm -rf ${TCLI_LINUXISOWITHPRESEED_WORKDIR}
mkdir ${TCLI_LINUXISOWITHPRESEED_WORKDIR}

#####[ Building name of new iso ]#####

TCLI_LINUXISOWITHPRESEED_ISO_SRC=$( find ${TCLI_LINUXISOWITHPRESEED_PATH_ISO}/${TCLI_LINUXISOWITHPRESEED_FILE_ISO} -name '*.iso' | grep -v preseed | head -n 1 )
TCLI_LINUXISOWITHPRESEED_ISO_PREFIX=$( echo "${TCLI_LINUXISOWITHPRESEED_ISO_SRC}" | sed 's/.iso//' )
TCLI_LINUXISOWITHPRESEED_ISO_TARGET="${TCLI_LINUXISOWITHPRESEED_ISO_PREFIX}-preseed.iso"

#####[ Extracting files from iso ]#####
xorriso -osirrox on -dev "$TCLI_LINUXISOWITHPRESEED_ISO_SRC" \
	-extract '/isolinux/isolinux.cfg' ${TCLI_LINUXISOWITHPRESEED_WORKDIR}/isolinux.cfg \
	-extract '/md5sum.txt' ${TCLI_LINUXISOWITHPRESEED_WORKDIR}/md5sum.txt \
	-extract '/install.amd/gtk/initrd.gz' ${TCLI_LINUXISOWITHPRESEED_WORKDIR}/initrd.gz

#####[ Adding preseed to initrd ]#####
cp preseed.cfg ${TCLI_LINUXISOWITHPRESEED_WORKDIR}/
(
	cd ${TCLI_LINUXISOWITHPRESEED_WORKDIR} &&
	gunzip initrd.gz
	chmod +w initrd
	echo "preseed.cfg" | cpio -o -H newc -A -F initrd
	gzip initrd

	#####[ Changing default boot menu timeout ]#####
	sed -i 's/timeout 0/timeout 1/' isolinux.cfg

	#####[ Fixing MD5 ]#####
	fixSum initrd.gz ./install.amd/gtk/initrd.gz
	fixSum isolinux.cfg ./isolinux/isolinux.cfg
)

cp setup.sh $TCLI_LINUXISOWITHPRESEED_WORKDIR/
(
	fixSum setup.sh ./tools/setup.sh
)

#####[ Writing new iso ]#####
rm "$TCLI_LINUXISOWITHPRESEED_ISO_TARGET"
xorriso -indev "$TCLI_LINUXISOWITHPRESEED_ISO_SRC" \
	-map $TCLI_LINUXISOWITHPRESEED_WORKDIR/isolinux.cfg '/isolinux/isolinux.cfg' \
	-map $TCLI_LINUXISOWITHPRESEED_WORKDIR/md5sum.txt '/md5sum.txt' \
	-map $TCLI_LINUXISOWITHPRESEED_WORKDIR/setup.sh '/tools/setup.sh' \
	-map $TCLI_LINUXISOWITHPRESEED_WORKDIR/initrd.gz '/install.amd/gtk/initrd.gz' \
	-boot_image isolinux dir=/isolinux \
	-outdev "$TCLI_LINUXISOWITHPRESEED_ISO_TARGET"

rm -rf $TCLI_LINUXISOWITHPRESEED_WORKDIR
