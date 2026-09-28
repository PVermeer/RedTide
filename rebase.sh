#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/pvermeer/redtide/main"

KEY_DIR="/etc/pki/containers"
POLICY_DIR="/etc/containers"
POLICY="${POLICY_DIR}/policy.json"
REGISTRIES_DIR="${POLICY_DIR}/registries.d"
REGISTRIES_CONFIG="${REGISTRIES_DIR}/redtide.yaml"

IMAGE="ghcr.io/pvermeer/redtide:stable"

PRIMARY_KEY="${KEY_DIR}/redtide-primary.pub"
SECONDARY_KEY="${KEY_DIR}/redtide-secondary.pub"

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

install -d -m 0755 "$KEY_DIR"
install -d -m 0755 "$POLICY_DIR"
install -d -m 0755 "$REGISTRIES_DIR"

echo "==> Downloading RedTide signing keys"

wget \
    --https-only \
    --secure-protocol=TLSv1_2 \
    -O "$PRIMARY_KEY" \
    "${REPO_RAW}/keys/cosign-redtide-primary.pub"

wget \
    --https-only \
    --secure-protocol=TLSv1_2 \
    -O "$SECONDARY_KEY" \
    "${REPO_RAW}/keys/cosign-redtide-secondary.pub"

chmod 0644 "$PRIMARY_KEY" "$SECONDARY_KEY"
restorecon -RF "$KEY_DIR" 2>/dev/null || true

echo "==> Configuring RedTide signing keys"

cat >"$REGISTRIES_CONFIG" <<'EOF'
docker:
  ghcr.io/pvermeer/redtide:
    use-sigstore-attachments: true
EOF

chmod 0644 "$REGISTRIES_CONFIG"
restorecon -v "$REGISTRIES_CONFIG" 2>/dev/null || true

if [[ ! -f "$POLICY" ]]; then
    cat >"$POLICY" <<'EOF'
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

cp -a "$POLICY" "${POLICY}.redtide-backup"

tmp_policy="$(mktemp)"

jq \
    --arg primary "$PRIMARY_KEY" \
    --arg secondary "$SECONDARY_KEY" \
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
    "$POLICY" >"$tmp_policy"

install -m 0644 "$tmp_policy" "$POLICY"
rm -f "$tmp_policy"

restorecon -v "$POLICY" 2>/dev/null || true

echo
echo "==> Rebasing to RedTide"
echo

rpm-ostree rebase "ostree-image-signed:registry:${IMAGE}"

echo
echo "RedTide has been staged successfully."
echo
echo "Reboot to complete the installation:"
echo
echo "    systemctl reboot"
