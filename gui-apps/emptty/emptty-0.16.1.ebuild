# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit go-module pam systemd

DESCRIPTION="Dead simple CLI Display Manager on TTY"
HOMEPAGE="https://github.com/tvrzna/emptty"
SRC_URI="https://github.com/tvrzna/emptty/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="network-sandbox"

DEPEND="sys-libs/pam"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.20"

src_compile() {
	ego build -o emptty .
}

src_install() {
	dobin emptty
	dodoc README.md SAMPLES.md
	doman res/emptty.1

	newpamd res/pam emptty
	systemd_dounit res/systemd-service
	newinitd res/openrc-service emptty
}
