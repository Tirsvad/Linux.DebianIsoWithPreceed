#!/bin/bash
run() {
  local _DIR=$(realpath $(dirname $(readlink -f ${BASH_SOURCE})))
  . $_DIR/settings.sh
  cp setup.sh $_DIR/../
  . $_DIR/../run.sh
  rm $_DIR/../setup.sh
}

run