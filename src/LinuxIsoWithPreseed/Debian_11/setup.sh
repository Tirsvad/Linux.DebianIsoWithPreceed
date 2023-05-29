#!/bin/bash
apt-get install -qq opehssh-server
[ -d /root/.ssh ] || mkdir -p /root/.ssh
cat <<EOF >/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDC+vJ885+wzYbwYZcKzZMKIVT2uGo8QYTxG73rLuApkJoU3D/MdQqUj9YvWk35k6L/TawFTvr3NOVDYj3n5svw6Tih6hxFc9oHkdj9/sz7z5MyuIjF80lQiYUpXvlEZkIR3QI4CS4JsLt/5FldQJpiJT62vStfNbWq3ig61/Ax3OuxwGuGbj+T7gzp1BfIXvhp+OH5uLmJnJ1apIlNb9Ia+XEUrGYvCKLmumgYzgyE/SPIBhMjlldKkgk/dxEa6aB9mmfQZ2N1UaEPQWMwzMsoVhKhMQbXA2ERCoX/IkdyxBQA8r9IYgOc79+h7OD80KcK1/bo7GN0LEkxbkdtgrqbztn4VJE7ivxHFTHJWEeCOlFbzKaHBptIqS4XE+o7qXhPw34oRdXFTtFo6qir47KccjQFFioEyOZ/r48O6rcRxF6lIHfn+bABZ0if0TDoT26RgI7PxBBa7IwsHWj32ZLUyk/iFod8juEA4taJ0SSqcxLUyN5X/RcGiP+RumiG7Qc= tirsvad@pc01
EOF
rm $(readlink -f $0)

