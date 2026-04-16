#!/bin/bash
set -e
set -o pipefail

script_dir=$(dirname "${BASH_SOURCE[0]}")
source "${script_dir}/bash-color.sh"

export FEDORA_VERSION
FEDORA_VERSION="$(rpm -E %fedora)"

echo "FEDORA_VERSION=$FEDORA_VERSION"
