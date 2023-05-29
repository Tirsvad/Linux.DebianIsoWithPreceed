#!/bin/bash

if [[ $0 == $BASH_SOURCE ]]; then
  echo "Script is being run directly!!"
  echo "Please use the script in one of the subdirectories"
  exit 1
fi

declare -g TCLI_LINUXISOWITHPRESEED_PATH_SOURCE=$(realpath $(dirname $(readlink -f ${BASH_SOURCE})))
declare -g TCLI_LINUXISOWITHPRESEED_FILE_ISO=$( wget -qO - ${TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL}/SHA512SUMS | grep netinst | grep -v mac | head -n 1 | awk '{ print $2 }' )

if ! type -t tcli_logger_init >/dev/null; then
  . $TCLI_LINUXISOWITHPRESEED_PATH_SOURCE/Vendor/Linux.Logger/src/Logger/run.sh
  [ -d ./log ] || mkdir ./log
  tcli_logger_init ./log/LinuxIsoWithPreseed.log
fi

printf "Building VM with $TCLI_LINUXISOWITHPRESEED_FILE_ISO\n" >&3

tcli_logger_infoscreen "Loading" "configuration"
. $TCLI_LINUXISOWITHPRESEED_PATH_SOURCE/conf.sh

[ -d ${TCLI_LINUXISOWITHPRESEED_PATH_WORK} ] || mkdir -p ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}
cd ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}

cp -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/preseed.cfg ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}/
# Changing the default with custom for this vm
[ -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/preseed.cfg ] && cp -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/preseed.cfg ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}
[ -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/setup.sh ] && cp -f ${TCLI_LINUXISOWITHPRESEED_PATH_SOURCE}/setup.sh ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}
tcli_logger_infoscreenDone

# stop and remove snapshot then delete old VM
[ $(virsh list --name --state-running | grep $TCLI_LINUXISOWITHPRESEED_VM_NAME) ] && (
  tcli_logger_infoscreen "stop"  "the old running VM $TCLI_LINUXISOWITHPRESEED_VM_NAME"
  virsh destroy $TCLI_LINUXISOWITHPRESEED_VM_NAME && tcli_logger_infoscreenDone || tcli_logger_infoscreenWarn
)

[ ! $(virsh snapshot-list --name --domain $TCLI_LINUXISOWITHPRESEED_VM_NAME 2>/dev/null) =="" ] && (
  tcli_logger_infoscreen "delete" "snapshot of $TCLI_LINUXISOWITHPRESEED_VM_NAME"
  for n in $(virsh snapshot-list --name --domain $TCLI_LINUXISOWITHPRESEED_VM_NAME); do
    virsh snapshot-delete $TCLI_LINUXISOWITHPRESEED_VM_NAME $n
  done
  tcli_logger_infoscreenDone
)

[ $(virsh list --name --all | grep $TCLI_LINUXISOWITHPRESEED_VM_NAME) ] && (
  tcli_logger_infoscreen "delete" "$TCLI_LINUXISOWITHPRESEED_VM_NAME"
  virsh undefine $TCLI_LINUXISOWITHPRESEED_VM_NAME --remove-all-storage
  tcli_logger_infoscreenDone
)

#
# Build ISO
#
. $TCLI_LINUXISOWITHPRESEED_PATH_SOURCE/build.sh

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
--connect qemu:///system \
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
--graphics spice 
tcli_logger_infoscreenDone
tcli_logger_infoscreen "Installing" "OS on VM"
[ ! $(virsh list --name --state-running | grep $TCLI_LINUXISOWITHPRESEED_VM_NAME) ] && virsh start $TCLI_LINUXISOWITHPRESEED_VM_NAME --autodestroy
tcli_logger_infoscreenDone

IP=$(sudo arp -n | grep $(virsh dumpxml $TCLI_LINUXISOWITHPRESEED_VM_NAME | grep "mac address" | awk -F\' '{ print $2}') | grep -Eo '^[^ ]+')

printf "\n\nVM server name $TCLI_LINUXISOWITHPRESEED_VM_NAME\n"
printf "IP $IP\n"
printf "To connect console at server type ssh root@$IP\n"

# cleanup
sudo rm -rf ${TCLI_LINUXISOWITHPRESEED_PATH_WORK}