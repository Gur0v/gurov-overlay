# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

inherit meson python-single-r1 xdg

DESCRIPTION="Bubblewrap based sandboxing utility"
HOMEPAGE="https://github.com/igo95862/bubblejail"
SRC_URI="https://github.com/igo95862/bubblejail/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc gui fish-completion bash-completion"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="
	dev-python/jinja2
	doc? ( app-text/scdoc )
"

DEPEND="
	${PYTHON_DEPS}
	sys-apps/bubblewrap
	sys-apps/xdg-dbus-proxy
	$(python_gen_cond_dep '
		dev-python/cattrs[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/tomli-w[${PYTHON_USEDEP}]
		sys-libs/libseccomp[${PYTHON_USEDEP}]
		gui? ( dev-python/pyqt6[${PYTHON_USEDEP}] )
	')
"

RDEPEND="
	${DEPEND}
	dev-util/desktop-file-utils
	x11-libs/libnotify
	x11-themes/hicolor-icon-theme
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_configure() {
	local emesonargs=(
		-Duse-vendored-python-lxns=enabled
		$(meson_use doc man)
	)

	meson_src_configure
}

src_install() {
	local INSTALL_TAGS="runtime"
	use doc && INSTALL_TAGS+=",man"
	use gui && INSTALL_TAGS+=",bubblejail-gui"
	use fish-completion && INSTALL_TAGS+=",fish-completion"
	use bash-completion && INSTALL_TAGS+=",bash-completion"

	meson_src_install --tags "${INSTALL_TAGS}"
	python_optimize
}
