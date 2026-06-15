# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB en-US es-419 es
	et fa fi fil fr gu he hi hr hu id it ja kn ko lt lv ml mr ms nb nl
	pl pt-BR pt-PT ro ru sk sl sr sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop pax-utils wrapper xdg

DESCRIPTION="Private, fast, and honest web browser based on Chromium"
HOMEPAGE="https://helium.computer/ https://github.com/imputnet/helium-linux"

MY_PN="helium"
MY_P="${MY_PN}-${PV}"

BASE_SRC_URI="https://github.com/imputnet/${MY_PN}-linux/releases/download/${PV}"
SRC_URI="${BASE_SRC_URI}/${MY_P}-x86_64_linux.tar.xz -> ${P}.tar.xz"

S="${WORKDIR}/${MY_P}-x86_64_linux"

LICENSE="GPL-3 BSD"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="qt6 selinux wayland"

RESTRICT="bindist mirror strip test"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	>=dev-libs/nss-3.26
	media-fonts/liberation-fonts
	media-libs/alsa-lib
	media-libs/libva
	media-libs/mesa[gbm(+)]
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( sys-libs/glibc )
	sys-libs/libcap
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	|| (
		x11-libs/gtk+:3[X]
		gui-libs/gtk:4[X]
	)
	x11-libs/libdrm
	>=x11-libs/libX11-1.5.0
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
	x11-misc/xdg-utils
	qt6? ( dev-qt/qtbase:6[gui,widgets] )
	selinux? ( sec-policy/selinux-chromium )
	wayland? ( media-video/pipewire )
"

QA_PREBUILT="*"

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd locales > /dev/null || die
	rm -f *.info || die
	chromium_remove_language_paks
	popd > /dev/null || die

	rm -f libqt5_shim.so || die
	if ! use qt6; then
		rm -f libqt6_shim.so || die
	fi

	if [[ -f helium-wrapper ]]; then
		sed -i -E "s|/opt/[^/]*/|/opt/${PN}/|g" helium-wrapper || die
	fi

	sed -i \
		-e "s|^Exec=.*|Exec=/usr/bin/${PN} %U|" \
		-e "s|^Icon=.*|Icon=${PN}|" \
		helium.desktop || die
}

src_install() {
	local destdir="/opt/${PN}"

	dodir "${destdir}"
	cp -pPR * "${ED}/${destdir}/" || die

	newicon -s 256 product_logo_256.png "${PN}.png"
	newmenu helium.desktop "${PN}.desktop"

	if [[ -f "${ED}/${destdir}/helium-wrapper" ]]; then
		make_wrapper "${PN}" "./helium-wrapper" "${destdir}"
	else
		make_wrapper "${PN}" "./helium" "${destdir}"
	fi

	pax-mark m "${ED}/${destdir}/${MY_PN}"
}
