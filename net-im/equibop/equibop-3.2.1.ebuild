# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit desktop

DESCRIPTION="Equibop is a fork of Vesktop"
HOMEPAGE="https://github.com/Equicord/Equibop"
SRC_URI="https://github.com/Equicord/Equibop/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Equibop-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="network-sandbox"

QA_PREBUILT="opt/equibop/*"

BDEPEND="
	net-libs/nodejs[npm]
	net-libs/bun
"

src_compile() {
	bun install || die "Failed to install dependencies via bun"
	bun run package:dir || die "Failed to package the application"
}

src_install() {
	insinto /opt/equibop
	doins -r dist/linux-unpacked/*

	newicon static/icon.png equibop.png

	fperms +x /opt/equibop/equibop
	fperms +x /opt/equibop/chrome-sandbox

	make_desktop_entry /opt/equibop/equibop Equibop equibop "Network;InstantMessaging;"
	dosym -r /opt/equibop/equibop /usr/bin/equibop
}
