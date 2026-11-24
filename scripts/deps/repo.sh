#!/bin/bash

set -e
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common/env.sh"

repo_dir="/usr/share/dnf5/repos.d"
repo_key_dir="/usr/share/pki/rpm-gpg/redtide"

install -d -m 0755 "$repo_dir" "$repo_key_dir"

repo_exists_in_file() {
    local repo_file=$1
    local repo_name=$2

    grep -qFx "[$repo_name]" "$repo_file"
}

enable_repo() {
    local repo_file=$1
    local repo_name=$2
    local repo_file_destination="$repo_file"

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
    local repo_file=$1
    local repo_name=$2
    local repo_file_destination="$repo_file"

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

enable_repo_external() {
    local repo_file=$1
    local repo_name=$2
    local repo_file_name repo_key

    repo_file_name=$(basename "$repo_file")
    repo_key="${repo_file_name##*/}"
    repo_key="RPM-GPG-KEY-${repo_key%.repo}"

    local repo_file_source="$repo_file"
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

    enable_repo "$repo_file_destination" "$repo_name"
}

disable_repo_external() {
    local repo_file=$1
    local repo_name=$2
    local repo_file_name repo_key

    repo_file_name=$(basename "$repo_file")
    repo_key="${repo_file_name##*/}"
    repo_key="RPM-GPG-KEY-${repo_key%.repo}"

    local repo_file_destination="${repo_dir}/${repo_file_name}"
    local repo_key_file_destination="${repo_key_dir}/${repo_key}"

    echo_color "Removing external repo '$repo_name' in $repo_file_destination"

    # This can fail because it can be run more than once for the same repo
    rm "$repo_file_destination" 2>/dev/null || echo "Repo already disabled"
    rm "$repo_key_file_destination" 2>/dev/null || echo "Repo already disabled"

    if [ -f "$repo_file_destination" ]; then
        echo_error "Repo file for '$repo_name' not removed!: $repo_file_destination"
        return 1
    fi
    if [ -f "$repo_key_file_destination" ]; then
        echo_error "Repo key for '$repo_name' not removed!: $repo_file_destination"
        return 1
    fi
}

enable_repos() {
    local -n repo_array=$1
    local repo_name is_found external_repo_file internal_repo_file

    for repo_name in "${repo_array[@]}"; do

        if [ "$repo_name" = "fedora" ] || [ "$repo_name" = "local" ]; then
            continue
        fi

        is_found="false"

        for external_repo_file in "${REPOS_DIR}"/*; do
            if repo_exists_in_file "$external_repo_file" "$repo_name"; then
                is_found="true"
                enable_repo_external "$external_repo_file" "$repo_name"
                break
            fi
        done

        if [ "$is_found" = "true" ]; then
            continue
        fi

        for internal_repo_file in "${repo_dir}"/*; do
            if repo_exists_in_file "$internal_repo_file" "$repo_name"; then
                is_found="true"
                enable_repo "$internal_repo_file" "$repo_name"
                break
            fi
        done

        if [ "$is_found" = "false" ]; then
            echo_error "Failed to enable ${repo_name}: not found!"
            return 1
        fi
    done
}

disable_repos() {
    local -n repo_array=$1
    local repo_name is_found external_repo_file internal_repo_file

    for repo_name in "${repo_array[@]}"; do
        if [ "$repo_name" = "fedora" ] || [ "$repo_name" = "local" ]; then
            continue
        fi

        is_found="false"

        for external_repo_file in "${REPOS_DIR}"/*; do
            if repo_exists_in_file "$external_repo_file" "$repo_name"; then
                is_found="true"
                disable_repo_external "$external_repo_file" "$repo_name"
                continue
            fi
        done

        for internal_repo_file in "${repo_dir}"/*; do
            if repo_exists_in_file "$internal_repo_file" "$repo_name"; then
                is_found="true"
                disable_repo "$internal_repo_file" "$repo_name"
                continue
            fi
        done

        if [ "$is_found" = "false" ]; then
            echo_error "Failed to disable ${repo_name}: not found!"
            return 1
        fi
    done
}
