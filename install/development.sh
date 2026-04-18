#!/bin/bash
# https://rpmfusion.org/Howto/OSTree?highlight=%28%5CbCategoryHowto%5Cb%29

script_dir=$(dirname "$0")
source "${script_dir}/../scripts/env.sh"

echo_color "==== Installing development packages ===="

enable_repo_extern vscode.repo code
rpm-ostree install code
disable_repo_extern vscode.repo code

rpm-ostree install \
	git \
	jq \
	curl \
	shellcheck \
	shfmt \
	flatpak-builder \
	dnf-plugins-core \
	rpmdevtools \
	rpmlint \
	gh \
	rustup \
	gcc \
	gcc-c++ \
	make \
	cmake \
	clang \
	python3 \
	python3-pip \
	pipx \
	doxygen \
	micromamba \
	nodejs \
	npm

ostree container commit
