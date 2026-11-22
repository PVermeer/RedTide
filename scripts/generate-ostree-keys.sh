#!/usr/bin/env bash

set -Eeuo pipefail

umask 077

mkdir -p "$(dirname "${BASH_SOURCE[0]}")/../generated-keys"

# Configuration
private_pem="$(dirname "${BASH_SOURCE[0]}")/../generated-keys/ostree-redtide-private.pem"
private_key="$(dirname "${BASH_SOURCE[0]}")/../generated-keys/ostree-redtide-private.key"
public_key="$(dirname "${BASH_SOURCE[0]}")/../generated-keys/ostree-redtide-public.key"

# Create temporary directory
tmp_dir=$(mktemp -d)
trap 'rm -rf -- "$tmp_dir"' EXIT

# Generate Ed25519 key pair
echo "Generating Ed25519 key pair..."

openssl genpkey \
    -algorithm ED25519 \
    -out "$private_pem"

# Extract 32-byte private seed
openssl pkey \
    -in "$private_pem" \
    -outform DER |
    tail -c 32 >"$tmp_dir/private-seed.bin"

# Extract 32-byte public key
openssl pkey \
    -in "$private_pem" \
    -pubout \
    -outform DER |
    tail -c 32 >"$tmp_dir/public-raw.bin"

# Generate OSTree-compatible 64-byte secret key
cat \
    "$tmp_dir/private-seed.bin" \
    "$tmp_dir/public-raw.bin" |
    base64 -w0 >"$private_key"

echo >>"$private_key"

# Export public key
base64 -w0 "$tmp_dir/public-raw.bin" >"$public_key"
echo >>"$public_key"

# Verify key sizes
private_size=$(base64 -d "$private_key" | wc -c)
public_size=$(base64 -d "$public_key" | wc -c)

if [[ "$private_size" -ne 64 || "$public_size" -ne 32 ]]; then
    echo "ERROR: Unexpected key sizes."
    exit 1
fi

# Set explicit permissions
chmod 600 "$private_key"
chmod 644 "$public_key"

echo
echo "Ed25519 key pair generated successfully."
echo
echo "Private key: $private_key ($private_size bytes)"
echo "Public key:  $public_key ($public_size bytes)"
echo
echo "Private key permissions: 600"
echo "Public key permissions:  644"
