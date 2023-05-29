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

  printf "***************************************************************************************************\n"
  printf "FILE $1\n"
  printf "PLACE $2\n"

	_MD5_LINE_BEFORE=$( grep "$_PLACE" md5sum.txt)
  if [ $? == 0 ]; then
    _MD5_BEFORE=$( echo "$_MD5_LINE_BEFORE" | awk '{ print $1 }' )
    _MD5_AFTER=$( md5sum "$_FILE" | awk '{ print $1 }' )
    _MD5_LINE_AFTER=$( echo "$_MD5_LINE_BEFORE" | sed -e "s#$_MD5_BEFORE#$_MD5_AFTER#" )
    sed -i -e "s#$_MD5_LINE_BEFORE#$_MD5_LINE_AFTER#" md5sum.txt
    echo "changing"
  else
    _MD5_AFTER=$( md5sum "$_FILE" | awk '{ print $1 }' )
    # sed -i -e "$a$_MD5_AFTER" md5sum.txt
    sed -i '$a'$_MD5_AFTER'  '$_PLACE md5sum.txt
    echo "Appending"
  fi
  printf "***************************************************************************************************\n"
}

if [[ $0 == $BASH_SOURCE ]]; then
  echo "Script is being run directly!!"
  echo "Please use the script in one of the subdirectories"
  exit 1
fi

if [ ! -f ${TCLI_LINUXISOWITHPRESEED_PATH_ISO}/${TCLI_LINUXISOWITHPRESEED_FILE_ISO} ]; then
	wget "${TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL}/${TCLI_LINUXISOWITHPRESEED_FILE_ISO}" -O "${TCLI_LINUXISOWITHPRESEED_PATH_ISO}/${TCLI_LINUXISOWITHPRESEED_FILE_ISO}"
fi

#####[ Working directory ]#####
[ -d ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO} ] && rm -rf ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}
mkdir ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}

tcli_logger_infoscreen "Building" "new iso"
#####[ Building name of new iso ]#####
TCLI_LINUXISOWITHPRESEED_ISO_SRC=$( cd ${TCLI_LINUXISOWITHPRESEED_PATH_ISO} && find ${TCLI_LINUXISOWITHPRESEED_FILE_ISO} -name '*.iso' | grep -v preseed | head -n 1 )
TCLI_LINUXISOWITHPRESEED_ISO_PREFIX=$( echo "${TCLI_LINUXISOWITHPRESEED_ISO_SRC}" | sed 's/.iso//' )
TCLI_LINUXISOWITHPRESEED_ISO_TARGET=${TCLI_LINUXISOWITHPRESEED_PATH_ISO}/${TCLI_LINUXISOWITHPRESEED_ISO_PREFIX}-preseed.iso
tcli_logger_infoscreenDone

#####[ Extracting files from iso ]#####
xorriso -osirrox on -dev "$TCLI_LINUXISOWITHPRESEED_PATH_ISO/$TCLI_LINUXISOWITHPRESEED_ISO_SRC" \
	-extract '/isolinux/isolinux.cfg' ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/isolinux.cfg \
  -extract '/isolinux/isolinux.bin' ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/isolinux.bin \
	-extract '/md5sum.txt' ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/md5sum.txt \
	-extract '/install.amd/gtk/initrd.gz' ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/initrd.gz

tcli_logger_infoscreen "Adding" "preseed to initrd"
#####[ Adding preseed to initrd ]#####
cp preseed.cfg ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/
(
  cd ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}
	gunzip initrd.gz
	chmod +w initrd
	echo "preseed.cfg" | cpio -o -H newc -A -F initrd
	gzip initrd

	#####[ Changing default boot menu timeout ]#####
  sed -i "s/timeout 1/timeout 0/" isolinux.cfg
	
	#####[ Fixing MD5 ]#####
	fixSum ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/initrd.gz ./install.amd/gtk/initrd.gz
	fixSum ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/isolinux.cfg ./isolinux/isolinux.cfg
  fixsum ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/isolinux.bin ./isolinux/isolinux.bin
)
tcli_logger_infoscreenDone

cp setup.sh $TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO/
(
  cd ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}
	fixSum setup.sh ./tools/setup.sh
)

tcli_logger_infoscreen "Create" "ISO file with preseed from $TCLI_LINUXISOWITHPRESEED_ISO_SRC"
#####[ Writing new iso ]#####
rm "$TCLI_LINUXISOWITHPRESEED_ISO_TARGET"
cd $TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO
xorriso -indev "$TCLI_LINUXISOWITHPRESEED_PATH_ISO/$TCLI_LINUXISOWITHPRESEED_ISO_SRC" \
  -map isolinux.cfg '/isolinux/isolinux.cfg' \
	-map md5sum.txt '/md5sum.txt' \
	-map setup.sh '/tools/setup.sh' \
	-map initrd.gz '/install.amd/gtk/initrd.gz' \
	-boot_image isolinux dir=/isolinux \
	-outdev "$TCLI_LINUXISOWITHPRESEED_ISO_TARGET"
tcli_logger_infoscreenDone

rm -rf $TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO
