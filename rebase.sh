#!/usr/bin/env bash
set -euo pipefail

repo_raw="https://raw.githubusercontent.com/pvermeer/redtide/main"

ostree_registry_config_source=${repo_raw}/spec-files/redtide-repo-setup/redtide.conf
ostree_commit_keys_source=${repo_raw}/spec-files/redtide-repo-setup/ostree-redtide.pub

ostree_registry_config_destination=/etc/ostree/remotes.d/redtide.conf
ostree_commit_keys_destination=/etc/ostree/remotes.d/ostree-redtide.pub

image="ghcr.io/pvermeer/redtide:stable"

cleanup_on_error() {
    local rc=$?
    trap - EXIT

    if [[ "$rc" -eq 0 ]]; then
        return
    fi

    echo
    echo "==> Something went wrong. Cleaning up..."

    for file in "${installed_files[@]}"; do
        echo "==> Removing $file"

        if ! rm -f "$file"; then
            echo "ERROR: Failed to remove $file" >&2
            rc=1
        fi
    done

    exit "$rc"
}
trap cleanup_on_error EXIT

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

    if ! wget \
        --https-only \
        --secure-protocol=TLSv1_2 \
        -O "$tmp" "$source"; then
        rm -f "$tmp"
        return 1
    fi

    if [[ ! -s "$tmp" ]]; then
        echo "ERROR: Downloaded file is empty: $source" >&2
        rm -f "$tmp"
        return 1
    fi

    if ! install -Dm0644 "$tmp" "$destination"; then
        rm -f "$tmp"
        return 1
    fi

    rm -f "$tmp"
    installed_files+=("$destination")
}

require_root
require_command wget
require_command rpm-ostree

installed_files=()

echo
echo "==> Installing RedTide remote registry"
echo

download_and_install "$ostree_registry_config_source" "$ostree_registry_config_destination"

echo
echo "==> Installing RedTide signing keys"
echo

download_and_install "$ostree_commit_keys_source" "$ostree_commit_keys_destination"

echo
echo "==> Rebasing to RedTide"
echo

rpm-ostree rebase "ostree-remote-registry:redtide:${image}"

echo
echo "RedTide has been staged successfully."
echo
echo "Reboot to complete the installation:"
echo
echo "    systemctl reboot"
