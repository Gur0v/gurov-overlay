# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit chromium-2 desktop linux-info optfeature pax-utils xdg

DESCRIPTION="All-in-one voice and text chat for gamers"
HOMEPAGE="https://discord.com/"
SRC_URI="https://dl-ptb.discordapp.net/apps/linux/${PV}/${PN}-${PV}.tar.gz"

S="${WORKDIR}/DiscordPTB"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip test"

RDEPEND="
	gnome-extra/zenity
	sys-libs/glibc
	|| (
		sys-devel/gcc
		llvm-runtimes/libgcc
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"

CONFIG_CHECK="~USER_NS"
QA_PREBUILT="opt/${PN}/*"

src_prepare() {
	default

	sed -i \
		-e "s|Exec=.*|Exec=/usr/bin/${PN}|" \
		-e "s|Icon=.*|Icon=${PN}|" \
		${PN}.desktop || die
}

src_configure() {
	default
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	dodir /opt/${PN}
	cp -a "${S}"/* "${ED}/opt/${PN}/" || die

	dosym ../../opt/${PN}/${PN} /usr/bin/${PN}

	newicon -s 256 discord.png ${PN}.png
	domenu ${PN}.desktop

	pax-mark -m "${ED}/opt/${PN}/${PN}"
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature_header "Install the following packages for additional support:"
	optfeature "sound support" media-sound/pulseaudio-daemon media-sound/apulse[sdk] media-video/pipewire
	optfeature "emoji support" media-fonts/noto-emoji
}
