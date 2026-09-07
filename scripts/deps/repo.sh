#!/bin/bash

set -e
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common/env.sh"

enable_repo() {
    local repo_file_name=$1
    local repo_name=$2

    local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"

    echo_color "Enabling repo '$repo_name' in $repo_file_destination"

    if [ ! -f "$repo_file_destination" ]; then
        echo_error "Repo file for '$repo_name' not found: $repo_file_destination"
        return 1
    fi

    sed -i "/^\[$repo_name\]/,/^\[/ s/enabled=0/enabled=1/" "$repo_file_destination"
}

disable_repo() {
    local repo_file_name=$1
    local repo_name=$2

    local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"

    echo_color "Disabling repo '$repo_name' in $repo_file_destination"

    if [ ! -f "$repo_file_destination" ]; then
        echo_error "Repo file for '$repo_name' not found: $repo_file_destination"
        return 1
    fi

    sed -i "/^\[$repo_name\]/,/^\[/ s/enabled=1/enabled=0/" "$repo_file_destination"
}

enable_repo_extern() {
    local repo_file_name=$1
    local repo_name=$2
    local repo_key

    repo_key="${repo_file_name##*/}"
    repo_key="RPM-GPG-KEY-${repo_key%.repo}"

    local repo_file_source="${REPOS_DIR}/${repo_file_name}"
    local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"

    local repo_key_file_source="${REPO_KEYS_DIR}/${repo_key}"
    local repo_key_file_destination="/etc/pki/rpm-gpg/${repo_key}"

    echo_color "Installing external repo '$repo_name' in $repo_file_source"

    if [ ! -f "$repo_file_source" ]; then
        echo_error "Repo source file for '$repo_name' not found: $repo_file_source"
        return 1
    fi
    if [ ! -f "$repo_key_file_source" ]; then
        echo_error "Repo key file for '$repo_name' not found: $repo_key_file_source"
        return 1
    fi

    cp "$repo_file_source" "$repo_file_destination"
    cp "$repo_key_file_source" "$repo_key_file_destination"

    enable_repo "$repo_file_name" "$repo_name"
}

disable_repo_extern() {
    local repo_file_name=$1
    local repo_name=$2

    repo_key="${repo_file_name##*/}"
    repo_key="RPM-GPG-KEY-${repo_key%.repo}"

    local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"
    local repo_key_file_destination="/etc/pki/rpm-gpg/${repo_key}"

    echo_color "Removing external repo '$repo_name' in $repo_file_destination"

    rm "$repo_file_destination"
    rm "$repo_key_file_destination"
}
