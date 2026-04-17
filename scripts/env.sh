#!/bin/bash
set -e
set -o pipefail

script_dir=$(dirname "${BASH_SOURCE[0]}")
source "${script_dir}/bash-color.sh"

export FEDORA_VERSION
export BUILD_DIR

FEDORA_VERSION="$(rpm -E %fedora)"
BUILD_DIR="/build"

echo_color "FEDORA_VERSION=$FEDORA_VERSION"

check_arguments() {
	for argument in "$@"; do
		if [ -z "$argument" ]; then
			echo_error "Undefined argument in function"
			return 1
		fi
	done
}

enable_repo() {
	local repo_file_name=$1
	local repo_name=$2

	echo_color "Enabling repo $repo_name in $repo_file_name"
	check_arguments "$1" "$2"

	local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"

	sed -i "/^\[$repo_name\]/,/^\[/ s/enabled=0/enabled=1/" "$repo_file_destination"
}

disable_repo() {
	local repo_file_name=$1
	local repo_name=$2

	echo_color "Disabling repo $repo_name in $repo_file_name"
	check_arguments "$1" "$2"

	local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"

	sed -i "/^\[$repo_name\]/,/^\[/ s/enabled=1/enabled=0/" "$repo_file_destination"
}

enable_repo_extern() {
	local repo_file_name=$1
	local repo_name=$2

	echo_color "Enabling external repo $repo_name in $repo_file_name"
	check_arguments "$1" "$2"

	local repo_file_source="${BUILD_DIR}/repos/${repo_file_name}"
	local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"

	cp "$repo_file_source" "$repo_file_destination"
	enable_repo "$repo_file_name" "$repo_name"
}

disable_repo_extern() {
	local repo_file_name=$1
	local repo_name=$2

	local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"
	check_arguments "$1" "$2"

	echo_color "Disabling external repo $repo_name in $repo_file_name"

	rm "$repo_file_destination"
}
