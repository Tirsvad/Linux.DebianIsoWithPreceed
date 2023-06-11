#!/bin/bash

run() {
	local _dir=$(realpath $(dirname $(readlink -f ${BASH_SOURCE})))
	[ -f _DIR/setup.sh ] && cp -f setup.sh $_dir/../
	. $_dir/settings.sh
	(
		. $(realpath $_dir/../run.sh) --vm-name ${_VM_NAME} --iso-url ${_ISO_URL}
		tcli_linuxisowithpreseed_run
	)
}

run