#!/bin/bash

set -e
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common/env.sh"

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
        mapfile -t keys < <(yq '.keys[]' <<<"$dconf")

        for key in "${keys[@]}"; do

            # echo "KEY: $key"

            key_name=$(yq '.key' <<<"$key")
            key_value=$(yq -o=json '.value' <<<"$key" | jq -c .)

            crudini --set "$dconf_file" "$schema" "$key_name" "$key_value"
        done
    done

    echo_color -e "Dconf override file:"
    cat $dconf_file
}
