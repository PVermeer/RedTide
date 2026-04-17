#!/bin/bash
# https://rpmfusion.org/Howto/OSTree?highlight=%28%5CbCategoryHowto%5Cb%29

script_dir=$(dirname "$0")
source "${script_dir}/../scripts/env.sh"

enable_repo_extern docker-ce.repo docker-ce-stable
rpm-ostree install \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin
disable_repo_extern docker-ce.repo docker-ce-stable

rpm-ostree install \
	distrobox

ostree container commit
