# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Claude License

EAPI=8

PYTHON_COMPAT=(python3_{12..15})

inherit python-any-r1

MY_PN="${PN#thunderbird-}"
AUTOCONFIG_COMMIT='52e19b4904720d88aaa3214e461f668cda67a389'

DESCRIPTION="Dove is configurations and advanced modifications for Mozilla Thunderbird"
HOMEPAGE="https://codeberg.org/celenity/Dove"
SRC_URI="
	https://codeberg.org/celenity/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://codeberg.org/celenity/Phoenix/archive/${PV}.tar.gz -> ${PN}-phoenix-${PV}.tar.gz
	https://github.com/thunderbird/autoconfig/archive/${AUTOCONFIG_COMMIT}.tar.gz
		-> ${PN}-autoconfig-${AUTOCONFIG_COMMIT}.tar.gz
"

S="${WORKDIR}/${MY_PN}"

LICENSE="GPL-3+"
LICENSE+=" MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	|| ( mail-client/thunderbird mail-client/thunderbird-bin )
"
BDEPEND="
	app-alternatives/awk
	app-shells/bash
	app-misc/jq
	dev-lang/python
	dev-python/lxml
"

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	default

	mkdir -p "${S}"/external || die
	mv "${WORKDIR}"/phoenix "${S}"/external/phoenix || die
	mv "${WORKDIR}"/autoconfig-${AUTOCONFIG_COMMIT} "${S}"/external/autoconfig || die
	sed -i -e '/^VIRTUAL_ENV=/d' -e '/^export VIRTUAL_ENV/d' "${S}"/scripts/env_external.sh || die
}

src_compile() {
	export DOVE_NIX=1
	export DOVE_BUILD="${WORKDIR}/build"
	export DOVE_OUTPUTS="${WORKDIR}/outputs"
	export DOVE_LOG_BUILD=0

	export DOVE_PYTHON="$(type -P python3)"
	export DOVE_SED="$(type -P sed)"
	export DOVE_AWK="$(type -P awk)"
	export DOVE_JQ="$(type -P jq)"
	export DOVE_RM="$(type -P rm)"
	export DOVE_MKDIR="$(type -P mkdir)"
	export DOVE_LN="$(type -P ln)"
	export DOVE_TEE="$(type -P tee)"
	export DOVE_DIRNAME="$(type -P dirname)"
	export DOVE_CP="$(type -P cp)"
	export DOVE_CAT="$(type -P cat)"
	export DOVE_UNAME="$(type -P uname)"

	bash scripts/build.sh 'linux' || die
}

src_install() {
	insinto "/etc/thunderbird"
	newins "${WORKDIR}"/outputs/linux/dove.cfg dove.cfg

	insinto "/etc/thunderbird/defaults/pref"
	newins "${WORKDIR}"/outputs/linux/defaults/pref/dove.js dove.js

	insinto "/etc/thunderbird/policies"
	newins "${WORKDIR}"/outputs/linux/policies/policies.json policies.json

	insinto "/etc/thunderbird/dove"
	doins -r "${WORKDIR}"/outputs/linux/assets
}

pkg_postinst() {
	elog "Alternatively: At the cost of privacy and security, after installing Dove,"
	elog "you can set the value of \`mailnews.auto_config_url\` to \`https://autoconfig.thunderbird.net/v1.1/\`"
	elog "from \`about:config\`."
	elog "This is NOT recommended, as it will share your email provider with Mozilla, and is slower/less responsive."
}
