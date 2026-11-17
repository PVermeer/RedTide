#!/bin/bash

set -Eeuo pipefail

# Configuration
image="localhost:5000/redtide"
containerfile="./Containerfile"
build_log="./build.log"
registry_container="registry"

silverblue_point_release_image_source="quay.io/fedora-ostree-desktops/silverblue"
silverblue_point_release=""

build_tag="build"
output_tag="latest"

# Build options
no_cache=false
no_rechunk=false
point_release=false
push=false

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --no-cache              Build without cache
  --no-rechunk            Skip OCI image rechunking
  --point-release RELEASE Build a Silverblue point release
                          Example: .20261016.0
  --push                  Push the final image to the local registry
  -h, --help              Show this help

Examples:
  $0
  $0 --no-cache
  $0 --no-rechunk
  $0 --point-release .20261016.0
  $0 --point-release .20261016.0 --no-cache --push
EOF
}

log() {
    echo
    echo "==> $*"
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
            echo "ERROR: --point-release requires a release value."
            exit 1
        }
        point_release=true
        silverblue_point_release="$2"
        shift
        ;;
    --push)
        push=true
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo "ERROR: Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
done

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
log "Building Silverblue image"

if [[ "$point_release" == true ]]; then
    echo "Image source: ${silverblue_point_release_image_source}"
    echo "Point release: ${silverblue_point_release}"
fi

podman build "${build_args[@]}" . 2>&1 | tee -a "$build_log"

# Rechunk image or use original build
if [[ "$no_rechunk" == true ]]; then
    log "Skipping image rechunking"

    podman tag \
        "${image}:${build_tag}" \
        "${image}:${output_tag}"
else
    # Rechunk image
    log "Rechunking image for bootc"

    # https://github.com/bootc-dev/bootc/issues/1885 left=right panic error. It's fixed but not here yet.
    # rpm-ostree:
    #     Version: '2026.3'
    #     Git: 937cd35dc42acb965b72e03f662cf4e19e770277
    # For now just remove previous image first
    podman rmi "${image}:${output_tag}" || :

    rpm-ostree compose build-chunked-oci \
        --bootc \
        --format-version=2 \
        --from="${image}:${build_tag}" \
        --output="containers-storage:${image}:${output_tag}" \
        2>&1 | tee -a "$build_log"
fi

# Optional local registry push
if [[ "$push" == true ]]; then
    log "Starting local registry"

    if ! podman container start "$registry_container" 2>/dev/null; then
        podman container run -d \
            -p 0.0.0.0:5000:5000 \
            --name "$registry_container" \
            docker.io/library/registry:latest
    fi

    log "Pushing image"

    podman push \
        --format=oci \
        "${image}:${output_tag}" \
        2>&1 | tee -a "$build_log"
fi

log "Build completed successfully"

echo "Image: ${image}:${output_tag}"
echo "Log:   ${build_log}"
