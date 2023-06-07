#!/bin/bash

## @file
## @author Jens Tirsvad Nielsen
## @brief Linux iso with preseed
## @details
## **Linux iso with preseed**
## Requires:
##	- 'xorriso' installed
##	  sudo apt install xorriso
##	- preseed.cfg
##	  1) Look at example http://www.debian.org/releases/stretch/example-preseed.txt
##	  2) Read manual https://www.debian.org/releases/stable/i386/apb.html
##	  3) Install manually and then export preseed answers:
##	     sudo apt-get install debconf-utils
##	     debconf-get-selections --installer >> preseed.cfg

if [[ $0 == $BASH_SOURCE ]]; then
	echo "Script is being run directly!!"
	echo "Please use the script in one of the subdirectories"
	exit 1
fi

## @brief string basepath of this script
declare -g TCLI_LINUXISOWITHPRESEED_PATH_SOURCE=$(realpath $(dirname $(readlink -f ${BASH_SOURCE})))
## @brief string filename of iso
declare -g TCLI_LINUXISOWITHPRESEED_FILE_ISO=$( wget -qO - ${TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL}/SHA512SUMS | grep netinst | grep -v mac | head -n 1 | awk '{ print $2 }' )

. $TCLI_LINUXISOWITHPRESEED_PATH_SOURCE/conf.sh

## @fn tcli_linuxisowithpreseed_init
## @details
tcli_linuxisowithpreseed_init() {
	type -t tcli_logger_init || {
		. $TCLI_LINUXISOWITHPRESEED_PATH_SOURCE/Vendor/Linux.Logger/src/Logger/run.sh;
		[ -d ./log ] || mkdir ./log;
		tcli_logger_init ./log/LinuxIsoWithPreseed.log;
	}
	tcli_logger_file_info "Loaded" "TCLI Linux iso with preseed"
}

## @fn tcli_linuxisowithpreseed_get_filename_from_iso
## @details
## Getting the filename of the iso
## @param string download url (only the path)
tcli_linuxisowithpreseed_get_filename_from_iso() {
	TCLI_LINUXISOWITHPRESEED_FILE_ISO=$( wget -qO - ${1:-}/SHA512SUMS | grep netinst | grep -v mac | head -n 1 | awk '{ print $2 }' )
}

## @fn tcli_linuxisowithpreseed_load_conf
## @details
tcli_linuxisowithpreseed_load_conf() {
	tcli_logger_file_info "tcli linuxisowithpreseed loading configuration"
	tcli_logger_infoscreen "Loading" "configuration"
	[ ${TCLI_LINUXISOWITHPRESEED_VIRT_INSTALL_QEMU_CONNECT} == 'qemu:///system' ] && {
		[[ $EUID -ne 0 ]] && {
			tcli_logger_infoscreenFailedExit 'This script must be run as' 'root';
		}
	}

	[ -d ${TCLI_LINUXISOWITHPRESEED_PATH_WORK} ] || mkdir -p ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}
	cd ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}

	cp -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/preseed.cfg ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}/
	# Changing the default with custom for this iso
	[ -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/preseed.cfg ] && cp -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/preseed.cfg ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}
	[ -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/setup.sh ] && cp -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/setup.sh ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}
	tcli_logger_infoscreenDone
}

## @fn tcli_linuxisowithpreseed_build_iso
## @details
tcli_linuxisowithpreseed_build_iso() {
	tcli_logger_file_info "tcli linuxisowithpreseed building iso"
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
		tcli_linuxisowithpreseed_fixSum ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/initrd.gz ./install.amd/gtk/initrd.gz
		tcli_linuxisowithpreseed_fixSum ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/isolinux.cfg ./isolinux/isolinux.cfg
		tcli_linuxisowithpreseed_fixSum ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/isolinux.bin ./isolinux/isolinux.bin
	)
	tcli_logger_infoscreenDone

	cp setup.sh ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}/
	(
		cd ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO}
		tcli_linuxisowithpreseed_fixSum setup.sh ./tools/setup.sh
	)

	tcli_logger_infoscreen "Create" "ISO file with preseed from ${TCLI_LINUXISOWITHPRESEED_ISO_SRC}"
	#####[ Writing new iso ]#####
	cd ${TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO} >/dev/null
	rm -f ${TCLI_LINUXISOWITHPRESEED_ISO_TARGET} >/dev/null
	$(xorriso -indev "${TCLI_LINUXISOWITHPRESEED_PATH_ISO}/${TCLI_LINUXISOWITHPRESEED_ISO_SRC}" \
		-map isolinux.cfg '/isolinux/isolinux.cfg' \
		-map md5sum.txt '/md5sum.txt' \
		-map setup.sh '/tools/setup.sh' \
		-map initrd.gz '/install.amd/gtk/initrd.gz' \
		-boot_image isolinux dir=/isolinux \
		-outdev "${TCLI_LINUXISOWITHPRESEED_ISO_TARGET}")
	tcli_logger_infoscreenDone
}

## @fn tcli_linuxisowithpreseed_vm_stop
## @details
## Stops vm if running
## @param string VM name
tcli_linuxisowithpreseed_vm_stop() {
	local _vm=${1:-}
	if [ ! ${_vm} ]; then
		tcli_logger_file_warn "VM name is empty" "func tcli_linuxisowithpreseed_vm_stop"
		return 1
	fi
	if [ $(virsh list --name --state-running | grep ${_vm}) ]; then
		tcli_logger_infoscreen "Stop"  "the old running VM ${_vm}"
		tcli_logger_file_info "stop VM ${_vm}"
		virsh destroy ${_vm} > /dev/null && tcli_logger_infoscreenDone || tcli_logger_infoscreenWarn
	else
			tcli_logger_file_info "skipped as no running VM ${_vm}"
	fi
}

## @fn tcli_linuxisowithpreseed_vm_destoy
## @details
## Remove vm if exist
## @param string VM name
tcli_linuxisowithpreseed_vm_destoy() {
	local _vm=${1:-}
	if [ ! ${_vm} ]; then
		tcli_logger_file_warn "VM name is empty" "func tcli_linuxisowithpreseed_vm_destoy"
		return 1
	fi

	[ ! $(virsh snapshot-list --name --domain ${_vm} 2>/dev/null) =="" ] && (
		tcli_logger_infoscreen "delete" "snapshot of ${_vm}"
		for n in $(virsh snapshot-list --name --domain ${_vm}); do
			$(virsh snapshot-delete ${_vm} $n)
		done
		tcli_logger_infoscreenDone
	) || tcli_logger_file_info "we found no vm" "linuxisowithpreseed_vm_destoy SKIPPED"

	[ $(virsh list --name --all | grep ${_vm}) ] && (
		tcli_logger_infoscreen "delete" "${_vm}"
		$(virsh undefine ${_vm} --remove-all-storage)
		tcli_logger_infoscreenDone
	)
}

## @fn tcli_linuxisowithpreseed_vm_create
## @details
## Create vm
## @param string VM name
tcli_linuxisowithpreseed_vm_create() {
	local _vm=${1:-}
	if [ ! ${_vm} ]; then
		tcli_logger_file_warn "VM name is empty" "func tcli_linuxisowithpreseed_vm_destoy"
		return 1
	fi

	tcli_logger_file_info "tcli linuxisowithpreseed building vm with $TCLI_LINUXISOWITHPRESEED_FILE_ISO"
	#
	# Build VM 
	#
	# ISO_SRC=$( find . -name '*.iso' | grep -v preseed | head -n 1 )
	# ISO_PREFIX=$( echo "$ISO_SRC" | sed 's/.iso//' )
	# ISO_TARGET="$ISO_PREFIX-preseed.iso"

	tcli_logger_infoscreen "Create" "VM $TCLI_LINUXISOWITHPRESEED_VM_NAME"
	[ -d $TCLI_LINUXISOWITHPRESEED_PATH_QCOW2 ] || mkdir -p $TCLI_LINUXISOWITHPRESEED_PATH_QCOW2
	[ -f $TCLI_LINUXISOWITHPRESEED_PATH_QCOW2/$TCLI_LINUXISOWITHPRESEED_FILE_QCOW2_NAME ] || qemu-img create -f qcow2 -o preallocation=off $TCLI_LINUXISOWITHPRESEED_PATH_QCOW2/$TCLI_LINUXISOWITHPRESEED_FILE_QCOW2_NAME 10G

	virt-install \
	--connect ${TCLI_LINUXISOWITHPRESEED_VIRT_INSTALL_QEMU_CONNECT} \
	--virt-type kvm \
	--name=$TCLI_LINUXISOWITHPRESEED_VM_NAME \
	--cdrom $TCLI_LINUXISOWITHPRESEED_ISO_TARGET \
	--disk $TCLI_LINUXISOWITHPRESEED_PATH_QCOW2/$TCLI_LINUXISOWITHPRESEED_FILE_QCOW2_NAME,bus=virtio,format=qcow2 \
	--vcpus 2 \
	--memory 2048 \
	--network default \
	--console pty,target_type=serial \
	--os-type=Linux \
	--os-variant=debian10 \
	--graphics ${TCLI_LINUXISOWITHPRESEED_VIRT_INSTALL_GRAPHICS} 
	tcli_logger_infoscreenDone

	tcli_logger_infoscreen "Installing" "OS on VM"
	[ ! $(virsh list --name --state-running | grep $TCLI_LINUXISOWITHPRESEED_VM_NAME) ] && $(virsh start $TCLI_LINUXISOWITHPRESEED_VM_NAME --autodestroy)
	tcli_logger_infoscreenDone

	IP=$(sudo arp -n | grep $(virsh dumpxml $TCLI_LINUXISOWITHPRESEED_VM_NAME | grep "mac address" | awk -F\' '{ print $2}') | grep -Eo '^[^ ]+')

	printf "\n\nVM server name $TCLI_LINUXISOWITHPRESEED_VM_NAME\n"
	printf "IP $IP\n"
	printf "To connect console at server type ssh root@$IP\n"
}


tcli_linuxisowithpreseed_fixSum() {
	local _FILE
	local _PLACE
	local _MD5_LINE_BEFORE
	local _MD5_BEFORE
	local _MD5_LINE_AFTER

	_FILE=$1
	_PLACE=$2

	_MD5_LINE_BEFORE=$( grep "$_PLACE" md5sum.txt)
	if [ $? == 0 ]; then
		_MD5_BEFORE=$( echo "$_MD5_LINE_BEFORE" | awk '{ print $1 }' )
		_MD5_AFTER=$( md5sum "$_FILE" | awk '{ print $1 }' )
		_MD5_LINE_AFTER=$( echo "$_MD5_LINE_BEFORE" | sed -e "s#$_MD5_BEFORE#$_MD5_AFTER#" )
		sed -i -e "s#$_MD5_LINE_BEFORE#$_MD5_LINE_AFTER#" md5sum.txt
		tcli_logger_file_info "Changing file $1 place $2 at iso image"
	else
		_MD5_AFTER=$( md5sum "$_FILE" | awk '{ print $1 }' )
		# sed -i -e "$a$_MD5_AFTER" md5sum.txt
		sed -i '$a'$_MD5_AFTER'  '$_PLACE md5sum.txt
		tcli_logger_file_info "Appending file $1 place $2 to iso image"
	fi
}

tcli_linuxisowithpreseed_cleanup() {
	sudo rm -rf ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}
	rm -rf $TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO
}

tcli_linuxisowithpreseed_run() {
	tcli_linuxisowithpreseed_init
	tcli_linuxisowithpreseed_get_filename_from_iso ${TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL}
	tcli_linuxisowithpreseed_load_conf
	tcli_linuxisowithpreseed_build_iso
	tcli_linuxisowithpreseed_vm_stop ${TCLI_LINUXISOWITHPRESEED_VM_NAME}
	tcli_linuxisowithpreseed_vm_destoy ${TCLI_LINUXISOWITHPRESEED_VM_NAME}
	tcli_linuxisowithpreseed_vm_create ${TCLI_LINUXISOWITHPRESEED_VM_NAME}
	tcli_linuxisowithpreseed_cleanup
}
