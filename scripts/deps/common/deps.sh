#!/bin/bash

echo_color "==== Checking dependencies ===="

needed_deps=(
	yq
	jq
	gettext # envsubst
	crudini
	rpm-sign
)
deps_to_install=()

for dep in "${needed_deps[@]}"; do
	if ! rpm -q "$dep" >/dev/null 2>&1; then
		echo_warning "Missing $dep"
		deps_to_install+=("$dep")
	fi
done

if [ ${#deps_to_install[@]} -ne 0 ]; then
	if command -v rpm-ostree >/dev/null 2>&1; then
		rpm-ostree install "${deps_to_install[@]}"
	else
		dnf -y install "${deps_to_install[@]}"
	fi
fi

# Alias the follwing commands so they will exit in a subshell $(command) on errors.

jq() {
	command yq "$@" || {
		echo_error "yq command failed: $*"
		exit 1
	}
}

yq() {
	command yq "$@" || {
		echo_error "yq command failed: $*"
		exit 1
	}
}
