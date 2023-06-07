#!/bin/bash
run() {
	local _dir=$(realpath $(dirname $(readlink -f ${BASH_SOURCE})))
	[ -f _DIR/setup.sh ] && cp -f setup.sh $_dir/../
	. $(realpath $_dir/../run.sh)
	# overrule default conf
	. $_dir/settings.sh
	tcli_linuxisowithpreseed_run
	# rm $_DIR/../setup.sh
}

run