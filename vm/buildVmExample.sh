#!/bin/bash
. settings.sh
SOURCEDIR=$(dirname $(readlink -f $0))"/"

[ -d $WORKDIR ] || sudo mkdir -p $WORKDIR
cd $WORKDIR
sudo cp $SOURCEDIR../src/DebianIsoWithPreseed/* $WORKDIR

# Create setup.sh file for run at the end of vm installation
VAR="#!/bin/bash
apt install -qq opehssh-server
[ -d /root/.ssh ] || mkdir -p /root/.ssh
cat <<EOF >/root/.ssh/authorized_keys
$SSH_KEY 
EOF"
cat <<EOF >$SOURCEDIR/setup.sh
$VAR
EOF

# Changing the default with custom for this vm
[ -f preseed.cfg ] && sudo cp -f ${SOURCEDIR}preseed.cfg $WORKDIR
[ -f setup.sh ] && sudo cp -f ${SOURCEDIR}setup.sh $WORKDIR

# stop and remove snapshot then delete old VM
[ $(sudo virsh list --name --state-running | grep $VM_NAME) ] && (
    sudo virsh destroy $VM_NAME
)

[ ! $(sudo virsh snapshot-list --name --domain $VM_NAME)=="" ] && (
    for n in $(sudo virsh snapshot-list --name --domain $VM_NAME); do
        sudo virsh snapshot-delete $VM_NAME $n
    done
)

[ $(sudo virsh list --name --all | grep $VM_NAME) ] && (
    sudo virsh undefine $VM_NAME --remove-all-storage
)

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
--network default \
--console pty,target_type=serial \
--os-type=Linux \
--os-variant=debian10 \
--graphics spice 

sudo rm -r $WORKDIR

[ ! $(sudo virsh list --name --state-running | grep $VM_NAME) ] && (
    sudo virsh start $VM_NAME --autodestroy
)

IP=$(sudo arp -n | grep $(sudo virsh dumpxml $VM_NAME | grep "mac address" | awk -F\' '{ print $2}') | grep -Eo '^[^ ]+')

echo "VM server name $VM_NAME"
echo "IP $IP"

echo "To connect console at server type ssh root@$IP"
