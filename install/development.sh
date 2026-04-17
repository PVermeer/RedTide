#!/bin/bash
# https://rpmfusion.org/Howto/OSTree?highlight=%28%5CbCategoryHowto%5Cb%29

script_dir=$(dirname "$0")
source "${script_dir}/../scripts/env.sh"

vscode_repo_file="/etc/yum.repos.d/vscode.repo"
cp $BUILD_DIR/repos/vscode.repo $vscode_repo_file
rpm-ostree install code
rm $vscode_repo_file

rpm-ostree install \
	shellcheck \
	shfmt \
	flatpak-builder \
	rpmdevtools \
	rpmlint \
	gh \
	rustup \
	make \
	cmake \
	clang \
	python3-pip \
	pipx \
	doxygen

ostree container commit
