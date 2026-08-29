#!/bin/bash

set -e
set -o pipefail

enable_extensions() {
    local -n extensions=$1

    if [ -n "${extensions[*]}" ]; then
        echo_color "Enabling extensions"

        enabled_extension_ids=()
        for extension in "${extensions[@]}"; do
            id=$(echo "$extension" | yq '.id' -)
            should_enable=$(echo "$extension" | yq '.enable' -)
            if [ "$should_enable" = "true" ]; then
                enabled_extension_ids+=("$id")
            fi
        done

        dconf_dir="/etc/dconf/db/local.d"
        dconf_file="$dconf_dir/00-gnome-shell"

        mkdir -p "$dconf_dir"

        printf -v extensions_dconf "'%s'," "${enabled_extension_ids[@]}"
        extensions_dconf="[${extensions_dconf%,}]"

        cat <<-EOF >>"$dconf_file"
			[org/gnome/shell]
			enabled-extensions=${extensions_dconf}
		EOF

        cat "$dconf_file"
        dconf update
    fi
}
