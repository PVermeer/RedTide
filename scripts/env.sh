#!/bin/bash
set -e
set -o pipefail

script_dir=$(dirname "${BASH_SOURCE[0]}")
source "${script_dir}/bash-color.sh"

export FEDORA_VERSION
export BUILD_DIR

FEDORA_VERSION="$(rpm -E %fedora)"
BUILD_DIR="/build"

echo "FEDORA_VERSION=$FEDORA_VERSION"
