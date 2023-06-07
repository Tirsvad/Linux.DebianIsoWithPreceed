echo '#!/bin/bash' > setup.sh
echo 'apt-get install -qq openssh-server' >> setup.sh
echo '[ -d /root/.ssh ] || mkdir -p /root/.ssh' >> setup.sh
if [ -f ~/.ssh/id_rsa.pub ]; then
	echo 'cat <<EOF >/root/.ssh/authorized_keys' >> setup.sh
	echo $(cat ~/.ssh/id_rsa.pub) >> setup.sh
	echo 'EOF' >> setup.sh
fi
echo 'rm $(readlink -f $0)' >> setup.sh
