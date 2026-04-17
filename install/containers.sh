#!/bin/bash
# https://rpmfusion.org/Howto/OSTree?highlight=%28%5CbCategoryHowto%5Cb%29

script_dir=$(dirname "$0")
source "${script_dir}/../scripts/env.sh"

docker_ce_repo_file="/etc/yum.repos.d/docker-ce.repo"
cp $BUILD_DIR/repos/docker-ce.repo $docker_ce_repo_file
rpm-ostree install \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin
rm $docker_ce_repo_file

rpm-ostree install \
	distrobox

ostree container commit
