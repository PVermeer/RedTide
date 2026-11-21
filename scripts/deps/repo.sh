#!/bin/bash

set -e
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common/env.sh"

repo_dir="/usr/share/dnf5/repos.d"
repo_key_dir="/usr/etc/pki/rpm-gpg/redtide"

install -d -m 0755 "$repo_dir" "$repo_key_dir"

repo_exists_in_file() {
    local repo_file=$1
    local repo_name=$2

    grep -qFx "[$repo_name]" "$repo_file"
}

find_repo_file() {
    local repo_name=$1
    local repo_file_name
    local repo_file_destination
    local repo_file_source

    for repo_file_name in "${repo_file_name_array[@]}"; do
        repo_file_destination="${repo_dir}/${repo_file_name}"
        repo_file_source="${REPOS_DIR}/${repo_file_name}"

        if [ -f "$repo_file_destination" ] &&
            repo_exists_in_file "$repo_file_destination" "$repo_name"; then
            REPO_FILE_NAME=$repo_file_name
            REPO_TYPE="internal"
            return 0
        fi

        if [ -f "$repo_file_source" ] &&
            repo_exists_in_file "$repo_file_source" "$repo_name"; then
            REPO_FILE_NAME=$repo_file_name
            REPO_TYPE="external"
            return 0
        fi
    done

    echo_error "Repository [$repo_name] not found in any repository file"
    return 1
}

enable_repo() {
    local repo_file_name=$1
    local repo_name=$2

    local repo_file_destination="${repo_dir}/${repo_file_name}"

    echo_color "Enabling repo '$repo_name' in $repo_file_destination"

    if [ ! -f "$repo_file_destination" ]; then
        echo_error "Repo file for '$repo_name' not found: $repo_file_destination"
        return 1
    fi

    if ! repo_exists_in_file "$repo_file_destination" "$repo_name"; then
        echo_error "Repository [$repo_name] not found in $repo_file_destination"
        return 1
    fi

    sed -i "/^\[$repo_name\]/,/^\[/ s/enabled=0/enabled=1/" "$repo_file_destination"

    if ! grep -A 20 "^\[$repo_name\]$" "$repo_file_destination" | grep -q "^enabled=1$"; then
        echo_error "Repository [$repo_name] failed to enable"
        return 1
    fi
}

disable_repo() {
    local repo_file_name=$1
    local repo_name=$2

    local repo_file_destination="${repo_dir}/${repo_file_name}"

    echo_color "Disabling repo '$repo_name' in $repo_file_destination"

    if [ ! -f "$repo_file_destination" ]; then
        echo_error "Repo file for '$repo_name' not found: $repo_file_destination"
        return 1
    fi

    if ! repo_exists_in_file "$repo_file_destination" "$repo_name"; then
        echo_error "Repository [$repo_name] not found in $repo_file_destination"
        return 1
    fi

    sed -i "/^\[$repo_name\]/,/^\[/ s/enabled=1/enabled=0/" "$repo_file_destination"

    if ! grep -A 20 "^\[$repo_name\]$" "$repo_file_destination" | grep -q "^enabled=0$"; then
        echo_error "Repository [$repo_name] failed to disable"
        return 1
    fi
}

enable_repo_extern() {
    local repo_file_name=$1
    local repo_name=$2
    local repo_key

    repo_key="${repo_file_name##*/}"
    repo_key="RPM-GPG-KEY-${repo_key%.repo}"

    local repo_file_source="${REPOS_DIR}/${repo_file_name}"
    local repo_file_destination="${repo_dir}/${repo_file_name}"

    local repo_key_file_source="${KEYS_DIR}/${repo_key}"
    local repo_key_file_destination="${repo_key_dir}/${repo_key}"

    echo_color "Installing external repo '$repo_name' in $repo_file_destination"

    if [ ! -f "$repo_file_source" ]; then
        echo_error "Repo source file for '$repo_name' not found: $repo_file_source"
        return 1
    fi

    if [ ! -f "$repo_key_file_source" ]; then
        echo_error "Repo key file for '$repo_name' not found: $repo_key_file_source"
        return 1
    fi

    echo "Copying repo file to: $repo_file_destination"
    if [ ! -s "$repo_file_destination" ]; then
        cp "$repo_file_source" "$repo_file_destination"
    fi

    echo "Copying key file to: $repo_key_file_destination"
    cp "$repo_key_file_source" "$repo_key_file_destination"

    enable_repo "$repo_file_name" "$repo_name"
}

disable_repo_extern() {
    local repo_file_name=$1
    local repo_name=$2
    local repo_key

    repo_key="${repo_file_name##*/}"
    repo_key="RPM-GPG-KEY-${repo_key%.repo}"

    local repo_file_destination="${repo_dir}/${repo_file_name}"
    local repo_key_file_destination="${repo_key_dir}/${repo_key}"

    echo_color "Removing external repo '$repo_name' in $repo_file_destination"

    # This can fail because it can be run more than once for the same repo
    rm "$repo_file_destination" 2>&1 || echo "Repo already disabled"
    rm "$repo_key_file_destination" 2>&1 || echo "Repo already disabled"
}

enable_repos() {
    local -n repo_file_name_array=$1
    local -n repo_array=$2

    local repo_name

    for repo_name in "${repo_array[@]}"; do
        [[ "$repo_name" == "fedora" || "$repo_name" == "local" ]] && continue

        find_repo_file "$repo_name" || return 1

        if [[ "$REPO_TYPE" == "internal" ]]; then
            enable_repo "$REPO_FILE_NAME" "$repo_name"
        else
            enable_repo_extern "$REPO_FILE_NAME" "$repo_name"
        fi
    done
}

disable_repos() {
    local -n repo_file_name_array=$1
    local -n repo_array=$2

    local repo_name

    for repo_name in "${repo_array[@]}"; do
        [[ "$repo_name" == "fedora" || "$repo_name" == "local" ]] && continue

        find_repo_file "$repo_name" || return 1

        if [[ "$REPO_TYPE" == "internal" ]]; then
            disable_repo "$REPO_FILE_NAME" "$repo_name"
        else
            disable_repo_extern "$REPO_FILE_NAME" "$repo_name"
        fi
    done
}
