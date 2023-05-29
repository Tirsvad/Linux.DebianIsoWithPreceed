#!/bin/bash

#
# Build VM 
#
# TCLI_LINUXISOWITHPRESEED_VM_NAME is the name of VM
# TCLI_LINUXISOWITHPRESEED_FILE_QCOW2_NAME is the filename of VM
# TCLI_LINUXISOWITHPRESEED_PATH_QCOW2 location where VM is saved
#
declare -g TCLI_LINUXISOWITHPRESEED_VM_NAME="debian_11_minimal"
declare -g TCLI_LINUXISOWITHPRESEED_FILE_QCOW2_NAME="debian-11-minimal.qcow2"
declare -g TCLI_LINUXISOWITHPRESEED_PATH_QCOW2="/srv/vm"

# Temp workdir
#declare -g TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL=https://cdimage.debian.org/cdimage/archive/11.6.0/amd64/iso-cd/
declare -g TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL=https://cdimage.debian.org/debian-cd/11.7.0/amd64/iso-cd/
# declare -g TCLI_LINUXISOWITHPRESEED_FILE_ISO_PRESEED=
