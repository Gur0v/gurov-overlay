# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit flag-o-matic git-r3 meson xdg

DESCRIPTION="A fullscreen overlay UI for GPU Screen Recorder in the style of ShadowPlay"
HOMEPAGE="https://git.dec05eba.com/gpu-screen-recorder-ui"
EGIT_REPO_URI="https://repo.dec05eba.com/gpu-screen-recorder-ui"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

DEPEND="
	dev-libs/glib:2
	dev-libs/wayland
	media-libs/freetype
	media-libs/libglvnd
	media-libs/libpulse
	sys-apps/dbus
	sys-kernel/linux-headers
	sys-libs/libcap
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/pango
"
RDEPEND="
	${DEPEND}
	media-video/gpu-screen-recorder
	media-video/gpu-screen-recorder-notification
"
BDEPEND="
	dev-build/meson
	dev-libs/wayland-protocols
	dev-util/desktop-file-utils
	dev-util/gtk-update-icon-cache
	virtual/pkgconfig
"

src_configure() {
	append-cxxflags -Wno-clobbered
	meson_src_configure
}
