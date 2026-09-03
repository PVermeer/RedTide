#!/bin/bash

echo_color "==== Checking dependencies ===="

needed_deps=(
	yq
	jq
	envsubst
	crudini
)
deps_to_install=()

for dep in "${needed_deps[@]}"; do
	if ! command -v "$dep" >/dev/null 2>&1; then
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
