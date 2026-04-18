#!/bin/bash
# https://rpmfusion.org/Howto/OSTree?highlight=%28%5CbCategoryHowto%5Cb%29

script_dir=$(dirname "$0")
source "${script_dir}/../scripts/env.sh"

echo_color "==== Installing Gnome Extensions ===="

rpm-ostree install \
	gnome-shell-extension-appindicator \
	gnome-shell-extension-caffeine \
	gnome-shell-extension-unite \
	gnome-shell-extension-blur-my-shell \
	gnome-shell-extension-just-perfection \
	gnome-shell-extension-screen-autorotate

ostree container commit
