# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Claude License

EAPI=8

PYTHON_COMPAT=(python3_{12..15})

inherit python-any-r1

MY_PN="${PN#firefox-}"

DESCRIPTION="Phoenix is configurations and advanced modifications for Mozilla Firefox"
HOMEPAGE="https://codeberg.org/celenity/Phoenix"
SRC_URI="https://codeberg.org/celenity/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	|| ( www-client/firefox www-client/firefox-bin )
"
BDEPEND="
	app-alternatives/awk
	app-arch/tar
	app-shells/bash
	app-misc/jq
	dev-lang/python
	dev-python/uv
"

pkg_setup() {
	python-any-r1_pkg_setup
}

src_compile() {
	export PHOENIX_NIX=1
	export PHOENIX_LINUX=1
	export PHOENIX_BUILD="${WORKDIR}/build"
	export PHOENIX_OUTPUTS="${WORKDIR}/outputs"
	export PHOENIX_LOG_BUILD=0

	export PHOENIX_UV="$(type -P uv)"
	export PHOENIX_PYTHON="$(type -P python3)"
	export PHOENIX_SED="$(type -P sed)"
	export PHOENIX_AWK="$(type -P awk)"
	export PHOENIX_JQ="$(type -P jq)"
	export PHOENIX_RM="$(type -P rm)"
	export PHOENIX_MKDIR="$(type -P mkdir)"
	export PHOENIX_LN="$(type -P ln)"
	export PHOENIX_TEE="$(type -P tee)"
	export PHOENIX_DIRNAME="$(type -P dirname)"
	export PHOENIX_CP="$(type -P cp)"
	export PHOENIX_CAT="$(type -P cat)"
	export PHOENIX_UNAME="$(type -P uname)"

	bash scripts/build.sh 'linux' || die
}

src_install() {
	insinto "/etc/firefox"
	newins "${WORKDIR}"/outputs/linux/phoenix.cfg phoenix.cfg

	insinto "/etc/firefox/defaults/pref"
	newins "${WORKDIR}"/outputs/linux/defaults/pref/phoenix.js phoenix.js

	insinto "/etc/firefox/policies"
	newins "${WORKDIR}"/outputs/linux/policies/policies.json policies.json
}
