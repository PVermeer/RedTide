#!/bin/bash
# https://rpmfusion.org/Howto/OSTree?highlight=%28%5CbCategoryHowto%5Cb%29

script_dir=$(dirname "$0")
source "${script_dir}/../scripts/env.sh"

enable_repo rpmfusion-nonfree-steam.repo rpmfusion-nonfree-steam
rpm-ostree install \
	steam \
	steam-devices
disable_repo rpmfusion-nonfree-steam.repo rpmfusion-nonfree-steam

enable_repo_extern pvermeer-gamescope-session-guide.repo copr:copr.fedorainfracloud.org:pvermeer:gamescope-session-guide
rpm-ostree install gamescope-session-guide
disable_repo_extern pvermeer-gamescope-session-guide.repo copr:copr.fedorainfracloud.org:pvermeer:gamescope-session-guide

enable_repo_extern pvermeer-sunshine.repo copr:copr.fedorainfracloud.org:pvermeer:sunshine
rpm-ostree install sunshine
disable_repo_extern pvermeer-sunshine.repo copr:copr.fedorainfracloud.org:pvermeer:sunshine

enable_repo_extern pvermeer-virtual-display.repo copr:copr.fedorainfracloud.org:pvermeer:virtual-display
rpm-ostree install virtual-display
disable_repo_extern pvermeer-virtual-display.repo copr:copr.fedorainfracloud.org:pvermeer:virtual-display

enable_repo_extern ilyaz-LACT.repo copr:copr.fedorainfracloud.org:ilyaz:LACT
rpm-ostree install lact
disable_repo_extern ilyaz-LACT.repo copr:copr.fedorainfracloud.org:ilyaz:LACT

enable_repo_extern faugus-faugus-launcher.repo copr:copr.fedorainfracloud.org:faugus:faugus-launcher
rpm-ostree install faugus-launcher
disable_repo_extern faugus-faugus-launcher.repo copr:copr.fedorainfracloud.org:faugus:faugus-launcher

rpm-ostree install \
	gamescope \
	gamemode \
	mangohud \
	goverlay \
	lutris

ostree container commit
