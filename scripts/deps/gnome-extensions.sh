#!/bin/bash

set -e
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/dconf.sh"

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
