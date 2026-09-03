#!/bin/bash

set -e
set -o pipefail

script_dir=$(dirname "${BASH_SOURCE[0]}")
source "${script_dir}/env.sh"

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

    local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"

    echo_color "Enabling repo '$repo_name' in $repo_file_destination"
    check_arguments "$1" "$2"

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
    check_arguments "$1" "$2"

    if [ ! -f "$repo_file_destination" ]; then
        echo_error "Repo file for '$repo_name' not found: $repo_file_destination"
        return 1
    fi

    sed -i "/^\[$repo_name\]/,/^\[/ s/enabled=1/enabled=0/" "$repo_file_destination"
}

enable_repo_extern() {
    local repo_file_name=$1
    local repo_name=$2

    local repo_file_source="${REPOS_DIR}/${repo_file_name}"
    local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"

    echo_color "Installing external repo '$repo_name' in $repo_file_source"
    check_arguments "$1" "$2"

    if [ ! -f "$repo_file_source" ]; then
        echo_error "Repo source file for '$repo_name' not found: $repo_file_source"
        return 1
    fi

    cp "$repo_file_source" "$repo_file_destination"

    enable_repo "$repo_file_name" "$repo_name"
}

disable_repo_extern() {
    local repo_file_name=$1
    local repo_name=$2

    local repo_file_destination="/etc/yum.repos.d/${repo_file_name}"
    check_arguments "$1" "$2"

    echo_color "Removing external repo '$repo_name' in $repo_file_destination"

    rm "$repo_file_destination"
}

set_dconf() {
    local -n dconf_values=$1
    local dconf_dir="/etc/dconf/db/local.d"
    local dconf_file="$dconf_dir/00-redtide"

    if [ "${dconf_values[*]}" = "null" ]; then
        echo_error "Setting dconf failed with 'null' input value"
        return 1
    fi

    echo_color "Setting dconf overrides"

    mkdir -p "$dconf_dir"
    touch "$dconf_file"

    for dconf in "${dconf_values[@]}"; do
        local schema keys key_name key_value

        schema=$(yq '.schema' <<<"$dconf")
        mapfile -t keys < <(yq -r '.keys[]' <<<"$dconf")

        for key in "${keys[@]}"; do
            key_name=$(yq '.key' <<<"$key")
            key_value=$(yq -o=json '.value' <<<"$key" | jq -c .)

            crudini --set "$dconf_file" "$schema" "$key_name" "$key_value"
        done
    done

    cat $dconf_file
}

enable_gnome_extensions() {
    local -n extensions=$1

    if [ -n "${extensions[*]}" ]; then
        echo_color "Enabling extensions"

        enabled_extension_ids=()
        for extension in "${extensions[@]}"; do
            local id should_enable

            id=$(echo "$extension" | yq '.id' -)
            should_enable=$(echo "$extension" | yq '.enable' -)
            if [ "$should_enable" = "true" ]; then
                enabled_extension_ids+=("$id")
            fi
        done

        # Format to json array ["abc", "def"]
        printf -v extensions_dconf_value "'%s'," "${enabled_extension_ids[@]}"
        extensions_dconf_value="[${extensions_dconf_value%,}]"

        # To dconf json inside a bash array for set_dconf argument
        export extensions_dconf_json=("$(
            extensions_dconf_value="$extensions_dconf_value" envsubst <<'EOF'
{
    "schema": "org/gnome/shell",
    "keys": [{
        "key": "enabled-extensions",
        "value": $extensions_dconf_value
    }]
}
EOF
        )")

        set_dconf extensions_dconf_json
    fi
}
