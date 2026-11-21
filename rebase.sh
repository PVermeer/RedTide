#!/usr/bin/env bash
set -euo pipefail

repo_raw="https://raw.githubusercontent.com/pvermeer/redtide/main"

ostree_registry_config_source="${repo_raw}/spec-files/redtide-repo-setup/redtide.conf"
ostree_commit_keys_source="${repo_raw}/spec-files/redtide-repo-setup/ostree-redtide.pub"

ostree_registry_config_destination="/etc/ostree/remotes.d/redtide.conf"
ostree_commit_keys_destination="/etc/ostree/remotes.d/ostree-redtide.pub"

container_policy="/etc/containers/policy.json"
default_container_policy="/usr/etc/containers/policy.json"

registry_config="/etc/containers/registries.d/redtide.yaml"
default_registry_config="/usr/etc/containers/registries.d/redtide.yaml"

image="ghcr.io/pvermeer/redtide:stable"

installed_files=()
restore_container_policy=false
restore_registry_config=false

cleanup_on_exit() {
    local rc=$?
    trap - EXIT

    # Not needed anymore for Fedora 45+, remove soon
    if [[ "${restore_container_policy}" == true ]]; then
        echo
        echo "==> Restoring default container signature policy"

        if [[ -f "${default_container_policy}" ]]; then
            if ! cp -a "${default_container_policy}" "${container_policy}"; then
                echo "ERROR: Failed to restore container signature policy!" >&2
                rc=1
            fi
        else
            if ! rm -f "${container_policy}"; then
                echo "ERROR: Failed to remove temporary container signature policy!" >&2
                rc=1
            fi
        fi
    fi

    # Not needed anymore for Fedora 45+, remove soon
    if [[ "${restore_registry_config}" == true ]]; then
        echo
        echo "==> Restoring default registry configuration"

        if [[ -f "${default_registry_config}" ]]; then
            if ! cp -a "${default_registry_config}" "${registry_config}"; then
                echo "ERROR: Failed to restore registry configuration!" >&2
                rc=1
            fi
        else
            if ! rm -f "${registry_config}"; then
                echo "ERROR: Failed to remove temporary registry configuration!" >&2
                rc=1
            fi
        fi
    fi

    if [[ "${rc}" -ne 0 ]]; then
        echo
        echo "==> Something went wrong. Cleaning up..."

        for file in "${installed_files[@]}"; do
            echo "==> Removing ${file}"

            if ! rm -f "${file}"; then
                echo "ERROR: Failed to remove ${file}" >&2
                rc=1
            fi
        done
    fi

    exit "${rc}"
}
trap cleanup_on_exit EXIT

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "This script must be run as root." >&2
        echo "Run: sudo $0" >&2
        exit 1
    fi
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Required command not found: $1" >&2
        exit 1
    fi
}

download_and_install() {
    local source="$1"
    local destination="$2"
    local tmp

    tmp=$(mktemp)

    if ! wget --https-only --secure-protocol=TLSv1_2 -O "${tmp}" "${source}"; then
        rm -f "${tmp}"
        return 1
    fi

    if [[ ! -s "${tmp}" ]]; then
        echo "ERROR: Downloaded file is empty: ${source}" >&2
        rm -f "${tmp}"
        return 1
    fi

    if ! install -Dm0644 "${tmp}" "${destination}"; then
        rm -f "${tmp}"
        return 1
    fi

    rm -f "${tmp}"
    installed_files+=("${destination}")
}

# Not needed anymore for Fedora 45+, remove soon
prepare_container_policy() {
    if [[ -f "${container_policy}" ]]; then
        echo "==> Installing temporary permissive container signature policy"

        cat >"${container_policy}" <<'EOF'
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ]
}
EOF

        restore_container_policy=true
    fi

    if [[ -f "${registry_config}" ]]; then
        echo "==> Removing RedTide registry configuration"
        rm -f "${registry_config}"
        restore_registry_config=true
    fi
}

require_root
require_command wget
require_command rpm-ostree

echo
echo "==> Installing RedTide remote registry"
echo

download_and_install "${ostree_registry_config_source}" "${ostree_registry_config_destination}"

echo
echo "==> Installing RedTide signing keys"
echo

download_and_install "${ostree_commit_keys_source}" "${ostree_commit_keys_destination}"

echo
echo "==> Preparing container configuration"
echo

prepare_container_policy

echo
echo "==> Rebasing to RedTide"
echo

rpm-ostree rebase "ostree-remote-registry:redtide:${image}"

echo
echo "==> Rebase completed"
echo

echo "RedTide has been staged successfully."
echo
echo "Reboot to complete the installation:"
echo
echo "    systemctl reboot"
