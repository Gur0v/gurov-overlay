# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit git-r3 meson xdg

DESCRIPTION="Notification in the style of ShadowPlay"
HOMEPAGE="https://git.dec05eba.com/gpu-screen-recorder-notification"
EGIT_REPO_URI="https://repo.dec05eba.com/gpu-screen-recorder-notification"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

DEPEND="
	dev-libs/wayland
	media-libs/libglvnd
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/pango
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/meson
	dev-libs/wayland-protocols
	virtual/pkgconfig
"
