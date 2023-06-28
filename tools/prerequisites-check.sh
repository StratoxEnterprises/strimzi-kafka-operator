#!/usr/bin/env bash
set -e

source $(dirname $(realpath $0))/../tools/multi-platform-support.sh

RED="\033[0;31m"
NO_COLOUR="\033[0m"

function check_command_present() {
    command -v "${1}" >/dev/null 2>&1 || { echo -e >&2 "${RED}I require ${1} but it's not installed.  Aborting.${NO_COLOUR}"; exit 1; }
}

check_command_present yq
check_command_present mvn
check_command_present git
check_command_present "${DOCKER_CMD:-docker}"
check_command_present shellcheck

# After version 3.3.1, yq --version sends the string to STDERR instead of STDOUT

