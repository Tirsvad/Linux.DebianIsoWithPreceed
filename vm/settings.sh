#!/bin/bash

#
# Build VM 
#
# VM_NAME is the name of VM
# QCOW2_FILENAME is the filename of VM
# QCOW2_PATH location where VM is saved
#
VM_NAME="debian11-minimal"
QCOW2_FILENAME="debian11-minimal.qcow2"
QCOW2_PATH="/srv/vm/"

WORKDIR="/var/tmp/vmDebian/"

#
#
#
#SSH_KEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCPWizgNlObHZtSbsMRm0HTCK7zavEseiTw5XyXOQyozib3PK2iqhLAhucamXD1uNqrd8X6gNy2CJAKEW1XM+VpVp1EKG2GzZ/+laGvLnt6qocA5uxiOrM7Zud8nephlFmPnyJnR1xd1UpW33ivXgPugdzSf/ETNCueZl1YaqSLF/wZ0EFVqR33F+jgGM1NXv7NlXNJXFhzpq2Ft888QlLPXH7RbZUYpdq0S8N3iezXckeqB+jJ7CR8FZjs7qejZozC1pfsQVhWV8Ey/L0DZ5UA7uaLQ/v9JRVOZCxnMEQos+xMz9tH9mSOaxD1wPlowqpPIV5/Q3K8v9Snu/3FEAsV user@localpc
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
