#!/bin/bash
set -e
set -o pipefail
shopt -s inherit_errexit

source "$(dirname "${BASH_SOURCE[0]}")/bash-color.sh"
source "$(dirname "${BASH_SOURCE[0]}")/deps.sh"

if [ -z "$BUILD_DIR" ]; then
	echo_error "BUILD_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$SCRIPTS_DIR" ]; then
	echo_error "SCRIPTS_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$PACKAGES_DIR" ]; then
	echo_error "PACKAGES_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$REPOS_DIR" ]; then
	echo_error "REPOS_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$KEYS_DIR" ]; then
	echo_error "KEYS_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$POLICIES_DIR" ]; then
	echo_error "POLICIES_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$KMODS_RPM_DIR" ]; then
	echo_error "KMODS_RPM_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$RPM_BUILD_DIR" ]; then
	echo_error "RPM_BUILD_DIR not defined in Containerfile"
	exit 1
fi
if [ -z "$LOCAL_RPM_DIR" ]; then
	echo_error "LOCAL_RPM_DIR not defined in Containerfile"
	exit 1
fi

export DISTRO_NAME
export FEDORA_VERSION

DISTRO_NAME="RedTide"
FEDORA_VERSION="$(rpm -E %fedora)"

echo_color "FEDORA_VERSION=$FEDORA_VERSION"

# Local RPM GPG key signing
mkdir -p "${KEYS_DIR}"

export RPM_LOCAL_SIGN_KEY="local_rpm"
export RPM_LOCAL_SIGN_KEY_FILE_PUBLIC="RPM-GPG-KEY-${RPM_LOCAL_SIGN_KEY}"
public_rpm_signing_key_path="${KEYS_DIR}/${RPM_LOCAL_SIGN_KEY_FILE_PUBLIC}"

if [ ! -s "$public_rpm_signing_key_path" ] &&
	! command -v rpm-ostree >/dev/null 2>&1; then

	echo_color "Setting gnupg config"
	# Set empty config, in particular to remove `use-keyboxd`. Some idiot designed gpg/keybox with
	# a bunch of extra deps / services needed + a locking database... which is all a massive PITA.
	mkdir -p "${HOME}/.gnupg"
	chmod 700 "${HOME}/.gnupg"
	echo "" >"${HOME}/.gnupg/common.conf"
	chmod 600 "${HOME}/.gnupg/common.conf"

	if ! gpg --batch --list-secret-keys $RPM_LOCAL_SIGN_KEY; then
		echo_color "Creating temporary rpm signing key"

		gpg --batch --passphrase '' \
			--quick-generate-key \
			"$RPM_LOCAL_SIGN_KEY" rsa4096 sign 0

		echo "Exporting public key to $public_rpm_signing_key_path"

		gpg --batch --armor --export $RPM_LOCAL_SIGN_KEY >"$public_rpm_signing_key_path"

		if [ ! -s "${KEYS_DIR}/$RPM_LOCAL_SIGN_KEY_FILE_PUBLIC" ]; then
			echo_error "Failed to export rpm signing public key"
			exit 1
		fi
	fi
elif [ -s "$public_rpm_signing_key_path" ]; then
	echo_color "Importing rpm signing public key"

	rpm --import "$public_rpm_signing_key_path"
else
	echo_error "Failed to manage local rpm signing key"
	exit 1
fi
