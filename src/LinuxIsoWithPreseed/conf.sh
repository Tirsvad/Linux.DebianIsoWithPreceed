#!/bin/bash

declare -g TCLI_LINUXISOWITHPRESEED_PATH_ISO=/srv/vm/iso
declare -g TCLI_LINUXISOWITHPRESEED_PATH_VM=/srv/vm

declare -g TCLI_LINUXISOWITHPRESEED_PATH_WORK=/var/tmp/tcli
declare -g TCLI_LINUXISOWITHPRESEED_PATH_WORK_ISO=/var/tmp/tcli/iso


# This will have some network issue
# declare -g TCLI_LINUXISOWITHPRESEED_VIRT_INSTALL_QEMU_CONNECT='qemu:///session'

# This require root privileges
declare -g TCLI_LINUXISOWITHPRESEED_VIRT_INSTALL_QEMU_CONNECT='qemu:///system'

declare -g TCLI_LINUXISOWITHPRESEED_VIRT_INSTALL_GRAPHICS=spice
