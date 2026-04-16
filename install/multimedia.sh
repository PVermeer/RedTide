#!/bin/bash
# https://rpmfusion.org/Howto/OSTree?highlight=%28%5CbCategoryHowto%5Cb%29

script_dir=$(dirname "$0")
source "${script_dir}/../scripts/env.sh"

rpm-ostree install \
	libva-utils \
	"https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
	"https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm" \

rpm-ostree install intel-media-driver

rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld

rpm-ostree install \
	gstreamer1-plugin-libav \
	gstreamer1-plugins-bad-free-extras \
	gstreamer1-plugins-bad-freeworld \
	gstreamer1-plugins-ugly \
	gstreamer1-vaapi \
	--allow-inactive

rpm-ostree override remove \
	fdk-aac-free \
	libavcodec-free \
	libavdevice-free \
	libavfilter-free \
	libavformat-free \
	libavutil-free \
	libpostproc-free \
	libswresample-free \
	libswscale-free \
	ffmpeg-free \
	--install ffmpeg

rpm-ostree override remove \
	rpmfusion-free-release \
  	rpmfusion-nonfree-release

ostree container commit
