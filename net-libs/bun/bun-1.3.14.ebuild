# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit shell-completion

DESCRIPTION="Fast all-in-one JavaScript runtime, bundler, transpiler and package manager"
HOMEPAGE="https://bun.sh https://github.com/oven-sh/bun"
SRC_URI="amd64? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64.zip -> ${P}-amd64.zip )"
S="${WORKDIR}/bun-linux-x64"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip test"

BDEPEND="app-arch/unzip"
RDEPEND="elibc_glibc? ( sys-libs/glibc )"

QA_PREBUILT="usr/bin/bun"

src_compile() {
	:
}

src_install() {
	dobin bun
	dosym bun /usr/bin/bunx

	einfo "Generating shell completions..."

	SHELL=zsh ./bun completions > bun.zsh || die
	SHELL=bash ./bun completions > bun.bash || die
	SHELL=fish ./bun completions > bun.fish || die

	newzshcomp bun.zsh _bun
	newbashcomp bun.bash bun
	newfishcomp bun.fish bun.fish
}
