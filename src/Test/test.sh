#!/bin/bash

## @file
## @author Jens Tirsvad Nielsen
## @brief Test Linux Iso With Preseed
## @details
## **Test virtual machine with Linux Iso incl Preseed**

declare -g TEST_PATH_SCRIPTDIR="$(dirname "$(realpath "${BASH_SOURCE}")")"
declare -g TEST_PATH_APP=$(realpath "${TEST_PATH_SCRIPTDIR}/../LinuxIsoWithPreseed")
declare -i -g TEST_PASSED=0
declare -i -g TEST_FAILED=0

. ${TEST_PATH_APP}/run.sh

## @fn info()
## @details
## **Info to screen**
## @param test message
info() {
	printf "          Test $1\r"
}

## @fn info_passed()
## @details
## **Info to screen**
## send "passed" in front of info message
## counting for later repport
info_passed() {
	printf " PASSED\n"
	TEST_PASSED+=1
}

## @fn info_passed()
## @details
## **Info to screen**
## send "failed" in front of info message
## counting for later repport
info_failed() {
	printf " FAILED\n"
	TEST_FAILED+=1
}
