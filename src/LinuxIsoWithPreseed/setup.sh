#!/bin/bash

# Script will run at the end of installation

# Will do everything in temporary files
cd /var/tmp

#
# SSH
#

#[ -d /root/.ssh ] || mkdir -p /root/.ssh
#cat <<EOF >/root/.ssh/authorized_keys
#ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCPWizgNlObHZtSbsMRm0HTCK7zavEseiTw5XyXOQyozib3PK2iqhLAhucamXD1uNqrd8X6gNy2CJAKEW1XM+VpVp1EKG2GzZ/+laGvLnt6qocA5uxiOrM7Zud8nephlFmPnyJnR1xd1UpW33ivXgPugdzSf/ETNCueZl1YaqSLF/wZ0EFVqR33F+jgGM1NXv7NlXNJXFhzpq2Ft888QlLPXH7RbZUYpdq0S8N3iezXckeqB+jJ7CR8FZjs7qejZozC1pfsQVhWV8Ey/L0DZ5UA7uaLQ/v9JRVOZCxnMEQos+xMz9tH9mSOaxD1wPlowqpPIV5/Q3K8v9Snu/3FEAsV user@localpc
#EOF
