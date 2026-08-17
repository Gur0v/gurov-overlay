# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit xdg

DESCRIPTION="Getting Things Done (GTD) productivity system for desktop"
HOMEPAGE="https://github.com/dongdongbh/Mindwtr"
SRC_URI="amd64? ( https://github.com/dongdongbh/Mindwtr/releases/download/v${PV}/mindwtr_${PV}_amd64.deb -> ${P}.deb )"
S="${WORKDIR}"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip test"

BDEPEND="app-arch/zstd"

RDEPEND="
	dev-libs/libayatana-appindicator
	net-libs/webkit-gtk:4.1
	x11-libs/gtk+:3
"

QA_PREBUILT="usr/bin/mindwtr"

src_unpack() {
	ar x "${DISTDIR}/${P}.deb" || die
	tar -xf data.tar.* || die
}

src_install() {
	cp -a usr "${ED}"/ || die
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "For GNOME system calendar integration, install"
	elog "  gnome-extra/evolution-data-server"
}

pkg_postrm() {
	xdg_pkg_postrm
}
