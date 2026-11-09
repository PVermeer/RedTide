#!/bin/bash

set -e
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/dconf.sh"

enable_gnome_extensions() {
    local -n extensions=$1
    local id should_enable extension
    local enabled_extension_ids=()
    local existing_extensions merged_extensions
    local dconf_dir="/etc/dconf/db/local.d"
    local dconf_file="$dconf_dir/00-redtide"

    if [ -n "${extensions[*]}" ]; then
        echo_color "Enabling extensions"

        for extension in "${extensions[@]}"; do

            id=$(echo "$extension" | yq '.id' -)
            should_enable=$(echo "$extension" | yq '.enable' -)
            if [ "$should_enable" = "true" ]; then
                enabled_extension_ids+=("$id")
            fi
        done

        if [ "${#enabled_extension_ids[@]}" -gt 0 ]; then
            mkdir -p "$dconf_dir"
            touch "$dconf_file"

            # Load existing enabled extensions, or initialize an empty array.
            existing_extensions=$(crudini --get \
                "$dconf_file" \
                org/gnome/shell \
                enabled-extensions 2>/dev/null || echo '[]')

            # Merge existing and new extension IDs, removing duplicates.
            merged_extensions=$(jq -cn \
                --argjson existing "$existing_extensions" \
                --args '$existing + $ARGS.positional | unique' \
                "${enabled_extension_ids[@]}")

            # Update the dconf file.
            crudini --set \
                "$dconf_file" \
                org/gnome/shell \
                enabled-extensions \
                "$merged_extensions"
        fi
    fi
}
