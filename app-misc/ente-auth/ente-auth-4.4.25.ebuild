# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit desktop wrapper xdg

DESCRIPTION="Open source 2FA authenticator, with end-to-end encrypted backups"
HOMEPAGE="https://ente.io/auth/ https://github.com/ente-io/ente"
SRC_URI="amd64? ( https://github.com/ente-io/ente/releases/download/auth-v${PV}/ente-auth-v${PV}-x86_64.AppImage -> ${P}-amd64.AppImage )"
S="${WORKDIR}/squashfs-root"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip test"

QA_PREBUILT="opt/enteauth/*"

RDEPEND="
	app-crypt/libsecret
	dev-libs/libayatana-appindicator
	dev-libs/openssl
	media-libs/libepoxy
	net-misc/curl
	virtual/zlib
	x11-libs/gtk+:3
"

src_unpack() {
	cp "${DISTDIR}/${P}-amd64.AppImage" "${WORKDIR}/${P}.AppImage" || die
	chmod +x "${WORKDIR}/${P}.AppImage" || die
	cd "${WORKDIR}" || die
	./${P}.AppImage --appimage-extract || die
}

src_prepare() {
	default
	sed -i 's:^Exec=.*:Exec=/usr/bin/enteauth:' enteauth.desktop || die
}

src_install() {
	dodir /opt/enteauth
	cp -a data lib enteauth "${ED}/opt/enteauth/" || die

	rm "${ED}/opt/enteauth/lib/libdartjni.so" || die

	make_wrapper enteauth "./enteauth" "/opt/enteauth"

	domenu enteauth.desktop

	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor

	insinto /usr/share/pixmaps
	doins *.png
}
