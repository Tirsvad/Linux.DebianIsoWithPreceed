#!/bin/bash
. settings.sh
SOURCEDIR=$(dirname $(readlink -f $0))"/"

[ -d $WORKDIR ] || sudo mkdir -p $WORKDIR
cd $WORKDIR
sudo cp $SOURCEDIR../src/DebianIsoWithPreseed/* $WORKDIR

# Changing the default with custom for this vm
[ -f preseed.cfg ] && sudo cp -f ${SOURCEDIR}preseed.cfg $WORKDIR

#
# Build ISO
#
sudo bash build.sh

#
# Build VM 
#
ISO_SRC=$( find . -name '*.iso' | grep -v preseed | head -n 1 )
ISO_PREFIX=$( echo "$ISO_SRC" | sed 's/.iso//' )
ISO_TARGET="$ISO_PREFIX-preseed.iso"

[ $(virsh list --name --all | grep $VM_NAME) ] && (
    sudo virsh destroy $VM_NAME
    sudo virsh undefine $VM_NAME --remove-all-storage
)
[ -d $QCOW2_PATH ] || mkdir -p $QCOW2_PATH
[ -f $QCOW2_PATH$QCOW2_FILENAME ] || sudo qemu-img create -f qcow2 -o preallocation=off $QCOW2_PATH$QCOW2_FILENAME 10G

sudo virt-install \
--connect qemu:///system \
--virt-type kvm \
--name=$VM_NAME \
--cdrom $ISO_TARGET \
--disk $QCOW2_PATH$QCOW2_FILENAME,bus=virtio,format=qcow2 \
--vcpus 2 \
--memory 2048 \
--network default,mac=52:54:00:6c:3c:01 \
--console pty,target_type=serial \
--os-type=Linux \
--os-variant=debian10 \
--graphics spice 

sudo rm -r $WORKDIR
