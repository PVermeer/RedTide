#!/bin/bash
set -e
set -o pipefail

script_dir=$(dirname "${BASH_SOURCE[0]}")
source "${script_dir}/bash-color.sh"
source "${script_dir}/deps.sh"

if [ -z "$BUILD_DIR" ]; then
	echo_error "BUILD_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$SCRIPTS_DIR" ]; then
	echo_error "SCRIPTS_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$PACKAGES_DIR" ]; then
	echo_error "PACKAGES_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$REPOS_DIR" ]; then
	echo_error "REPOS_DIR not defined in Containerfile"
	exit 1
fi

export DISTRO_NAME
export FEDORA_VERSION

DISTRO_NAME="RedTide"
FEDORA_VERSION="$(rpm -E %fedora)"

echo_color "FEDORA_VERSION=$FEDORA_VERSION"

check_arguments() {
	for argument in "$@"; do
		if [ -z "$argument" ]; then
			echo_error "Undefined argument in function"
			return 1
		fi
	done
}
