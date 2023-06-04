#!/bin/bash
run() {
	local _DIR=$(realpath $(dirname $(readlink -f ${BASH_SOURCE})))
	. $_DIR/settings.sh
	cp setup.sh $_DIR/../
	. $_DIR/../run.sh
	tcli_linuxisowithpreseed_run
	rm $_DIR/../setup.sh
}

run