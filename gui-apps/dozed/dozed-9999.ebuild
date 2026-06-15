# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit meson

DESCRIPTION="Lightweight, fullscreen-aware Wayland idle daemon (swayidle fork)"
HOMEPAGE="https://github.com/Gur0v/dozed"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Gur0v/dozed.git"
else
	SRC_URI="https://github.com/Gur0v/dozed/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="logind"

DEPEND="
	dev-libs/wayland
	logind? ( sys-apps/dbus )
"
RDEPEND="${DEPEND}"
BDEPEND="
	app-text/scdoc
	>=dev-libs/wayland-protocols-1.40
	>=dev-util/wayland-scanner-1.14.91
	virtual/pkgconfig
	|| ( dev-lang/rust-bin dev-lang/rust )
"

src_configure() {
	local emesonargs=(
		-Dman-pages=enabled
		-Dbash-completions=true
		-Dfish-completions=true
		-Dzsh-completions=true
		$(meson_feature logind)
	)

	meson_src_configure
}
