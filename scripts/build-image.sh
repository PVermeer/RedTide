#!/bin/bash

set -Eeuo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/deps/common/bash-color.sh"
if [ -f "$(dirname "${BASH_SOURCE[0]}")/../.env" ]; then
    # shellcheck disable=SC1091
    source "$(dirname "${BASH_SOURCE[0]}")/../.env"
fi

# Configuration
image="localhost:5000/redtide-dev"
containerfile="./Containerfile"
build_log="./build.log"
registry_container="registry"
keys_dir="./generated-keys" # keys generated with script used for testing

silverblue_point_release_image_source="quay.io/fedora-ostree-desktops/silverblue"
silverblue_point_release=""

build_tag="build"
output_tag="dev"

# Build options
no_cache=false
no_rechunk=false
point_release=false
push=false
sign=false

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --no-cache              Build without cache
  --no-rechunk            Skip OCI image rechunking
  --point-release RELEASE Build a Silverblue point release
                          Example: .20261016.0
  --sign                  Sign the OSTree commit during rechunking
                          (requires --rechunk; requires private key path in .env
  --push                  Push the final image to the local registry
  -h, --help              Show this help

Examples:
  $0
  $0 --no-cache
  $0 --no-rechunk
  $0 --sign --push
  $0 --point-release .20261016.0 --no-cache --sign --push
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
    --no-cache)
        no_cache=true
        ;;
    --no-rechunk)
        no_rechunk=true
        ;;
    --point-release)
        [[ $# -ge 2 && -n "$2" ]] || {
            echo_error "--point-release requires a release value."
            exit 1
        }
        point_release=true
        silverblue_point_release="$2"
        shift
        ;;
    --sign)
        sign=true
        ;;
    --push)
        push=true
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
done

if [[ "$sign" == true && "$no_rechunk" == true ]]; then
    echo_error "--sign requires rechunking (conflicts with --no-rechunk)."
    exit 1
fi

# Prepare build arguments
build_args=(
    --pull
    -f "$containerfile"
    -t "${image}:${build_tag}"
)

if [[ "$no_cache" == true ]]; then
    build_args+=(--no-cache)
fi

if [[ "$point_release" == true ]]; then
    build_args+=(
        --build-arg
        "SILVERBLUE_IMAGE_SOURCE=${silverblue_point_release_image_source}"
        --build-arg
        "SILVERBLUE_POINT_RELEASE=${silverblue_point_release}"
    )
fi

# Reset build log
: >"$build_log"

# Build image
echo_color "Building Silverblue image"

if [[ "$point_release" == true ]]; then
    echo "Image source: ${silverblue_point_release_image_source}"
    echo "Point release: ${silverblue_point_release}"
fi

podman build "${build_args[@]}" . 2>&1 | tee -a "$build_log"

# Rechunk image or use original build
if [[ "$no_rechunk" == true ]]; then
    echo_color "Skipping image rechunking"

    podman tag \
        "${image}:${build_tag}" \
        "${image}:${output_tag}"
else
    # Rechunk image
    echo_color "Rechunking image for bootc"

    # https://github.com/bootc-dev/bootc/issues/1885 left=right panic error. It's fixed but not here yet.
    # rpm-ostree:
    #     Version: '2026.3'
    #     Git: 937cd35dc42acb965b72e03f662cf4e19e770277
    # For now just remove previous image first
    echo_warning "Removing previous image if exists, because of bug in rechunker"
    podman rmi "${image}:${output_tag}" || :

    rechunk_args=(
        --bootc
        --format-version=2
        --from="${image}:${build_tag}"
        --output="containers-storage:${image}:${output_tag}"
    )

    if [[ "$sign" == true ]]; then
        private_key="${keys_dir}/ostree-redtide-private.key"

        if [ ! -f "$private_key" ]; then
            echo_error "--sign requires a private key: $private_key. Generate new keys with ./scripts/generate-ostree-keys.sh"
            exit 1
        fi

        echo_color "Signing OSTree commit with key $private_key"

        rechunk_args+=(
            --sign-commit=ed25519="$private_key"
        )
    fi

    rpm-ostree compose build-chunked-oci \
        "${rechunk_args[@]}" \
        2>&1 | tee -a "$build_log"
fi

# Optional local registry push
if [[ "$push" == true ]]; then
    echo_color "Starting local registry"

    if ! podman container start "$registry_container" 2>/dev/null; then
        podman container run -d \
            -p 0.0.0.0:5000:5000 \
            --name "$registry_container" \
            docker.io/library/registry:latest
    fi

    echo_color "Pushing image"

    podman push \
        --format=oci \
        "${image}:${output_tag}" \
        2>&1 | tee -a "$build_log"
fi

echo_color "Build completed successfully"

echo "Image: ${image}:${output_tag}"
echo "Log:   ${build_log}"
