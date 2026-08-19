# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

PYTHON_COMPAT=( python3_{10..15} )

inherit gnome2-utils meson python-single-r1 xdg

DESCRIPTION="Manage AppImages with ease"
HOMEPAGE="https://github.com/mijorus/gearlever"
SRC_URI="https://github.com/mijorus/gearlever/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	gui-libs/libadwaita:1
"

RDEPEND="
	${DEPEND}
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/desktop-entry-lib[${PYTHON_USEDEP}]
		dev-python/ftputil[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
	')
	app-arch/7zip
	sys-fs/squashfs-tools
"

BDEPEND="
	${PYTHON_DEPS}
	dev-util/desktop-file-utils
	dev-util/gtk-update-icon-cache
	sys-devel/gettext
	virtual/pkgconfig
"

src_install() {
	meson_src_install

	rm -f "${ED}/usr/share/gearlever/gearlever/assets/demo.AppImage" || die

	newbin build-aux/get_appimage_offset.sh get_appimage_offset

	python_fix_shebang "${ED}/usr/bin"
	python_optimize "${ED}/usr/share/gearlever"
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
