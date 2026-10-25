#!/usr/bin/env bash
set -euo pipefail

repo_raw="https://raw.githubusercontent.com/pvermeer/redtide/main"

key_dir="/etc/pki/containers"
policy_dir="/etc/containers"
policy="${policy_dir}/policy.json"
policy_backup="${policy}.redtide-backup"
registries_dir="${policy_dir}/registries.d"
registries_config="${registries_dir}/redtide.yaml"

image="ghcr.io/pvermeer/redtide:stable"

primary_key="${key_dir}/redtide-primary.pub"
secondary_key="${key_dir}/redtide-secondary.pub"

restore_policy() {
    local rc=$?
    trap - EXIT

    if [[ -f "$policy_backup" ]]; then
        echo
        echo "==> Restoring original container policy"

        if cp -a "$policy_backup" "$policy"; then
            rm -f "$policy_backup"
            restorecon -v "$policy" 2>/dev/null || true
            echo "Original policy restored."
        else
            echo "ERROR: Failed to restore original policy from $policy_backup" >&2
            rc=1
        fi
    fi

    exit "$rc"
}
trap restore_policy EXIT

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

require_root

require_command wget
require_command jq
require_command rpm-ostree

echo "==> Creating required directories"

install -d -m 0755 "$key_dir"
install -d -m 0755 "$policy_dir"
install -d -m 0755 "$registries_dir"

echo "==> Downloading RedTide signing keys"

wget \
    --https-only \
    --secure-protocol=TLSv1_2 \
    -O "$primary_key" \
    "${repo_raw}/keys/cosign-redtide-primary.pub"

wget \
    --https-only \
    --secure-protocol=TLSv1_2 \
    -O "$secondary_key" \
    "${repo_raw}/keys/cosign-redtide-secondary.pub"

chmod 0644 "$primary_key" "$secondary_key"
restorecon -RF "$key_dir" 2>/dev/null || true

echo "==> Configuring RedTide signing keys"

cat >"$registries_config" <<'EOF'
docker:
  ghcr.io/pvermeer/redtide:
    use-sigstore-attachments: true
EOF

chmod 0644 "$registries_config"
restorecon -v "$registries_config" 2>/dev/null || true

if [[ ! -f "$policy" ]]; then
    cat >"$policy" <<'EOF'
{
  "default": [
    {
      "type": "reject"
    }
  ],
  "transports": {
    "docker": {}
  }
}
EOF
fi

if [[ ! -f "$policy_backup" ]]; then
    cp -a "$policy" "$policy_backup"
else
    echo "WARN: Using existing policy backup: $policy_backup" >&2
fi

tmp_policy="$(mktemp)"

jq \
    --arg primary "$primary_key" \
    --arg secondary "$secondary_key" \
    '
    .default = [
        {
            "type": "reject"
        }
    ]
    |
    .transports.docker["ghcr.io/pvermeer/redtide"] = [
        {
            "type": "sigstoreSigned",
            "keyPaths": [
                $primary,
                $secondary
            ],
            "signedIdentity": {
                "type": "matchRepository"
            }
        }
    ]
    ' \
    "$policy" >"$tmp_policy"

install -m 0644 "$tmp_policy" "$policy"
rm -f "$tmp_policy"

restorecon -v "$policy" 2>/dev/null || true

echo
echo "==> Rebasing to RedTide"
echo

rpm-ostree rebase "ostree-image-signed:registry:${image}"

echo
echo "RedTide has been staged successfully."
echo
echo "Reboot to complete the installation:"
echo
echo "    systemctl reboot"
