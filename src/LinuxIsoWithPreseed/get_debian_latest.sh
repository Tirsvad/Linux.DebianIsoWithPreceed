#!/bin/bash

## @file
## @author Jens Tirsvad Nielsen
## @brief Debian Iso incl Preseed.cfg
## @details
## **Create iso with latest debian version incl preseed.cfg**
## Requires:
##	- 'xorriso' installed
##	  sudo apt install xorriso
##	- preseed.cfg
##	  1) Look at example http://www.debian.org/releases/stretch/example-preseed.txt
##	  2) Read manual https://www.debian.org/releases/stable/i386/apb.html
##	  3) Install manually and then export preseed answers:
##	     sudo apt-get install debconf-utils
##	     debconf-get-selections --installer >> preseed.cfg
## This script downloads Debians's iso and makes it auto-install

# declare -g BASE_URL=https://cdimage.debian.org/debian-cd/current/amd64/iso-cd
declare -g TCLI_LINUXISOWITHPRESEED_DOWNLOAD_URL=https://cdimage.debian.org/debian-cd/current/amd64/iso-cd
declare -g TCLI_LINUXISOWITHPRESEED_FILE_ISO=
declare -g TCLI_LINUXISOWITHPRESEED_FILE_ISO_PRESEED=

. ./conf.sh
. ./build.sh 