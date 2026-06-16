# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

WX_GTK_VER="3.2-gtk3"
inherit desktop eapi9-ver linux-info pax-utils toolchain-funcs wxwidgets

DESCRIPTION="Disk encryption with strong security based on TrueCrypt"
HOMEPAGE="https://www.veracrypt.fr/en/Home.html"
SRC_URI="https://github.com/${PN}/VeraCrypt/archive/VeraCrypt_${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/VeraCrypt-VeraCrypt_${PV}/src"

LICENSE="Apache-2.0 BSD RSA truecrypt-3.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="+asm cpu_flags_x86_sse2 cpu_flags_x86_sse4_1 cpu_flags_x86_ssse3 doc X"
RESTRICT="bindist mirror"

RDEPEND="
	sys-apps/pcsc-lite
	sys-fs/fuse:0
	sys-fs/lvm2
	x11-libs/wxGTK:${WX_GTK_VER}=[X?]"
DEPEND="${RDEPEND}"
BDEPEND="
	asm? ( dev-lang/yasm )
	virtual/pkgconfig"

CONFIG_CHECK="~BLK_DEV_DM ~CRYPTO ~CRYPTO_XTS ~DM_CRYPT ~FUSE_FS"

src_prepare() {
	# -march=x86-64-v3 defines __AVX2__; Crypto/cpu.h also re-enables it via
	# #pragma GCC target. Insert undefs directly before blamka-round-opt.h
	# so the SSE2 branch (which defines BLAKE2_ROUND) is always selected.
	sed -i \
		's|^#include "blake2/blamka-round-opt.h"$|#undef __AVX2__\n#undef __AVX512F__\n&|' \
		Crypto/Argon2/src/opt_sse2.c || die
	eapply_user
}

src_configure() {
	setup-wxwidgets
}

src_compile() {
	local myemakeargs=(
		"SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-$(date -r "${S}/Common/Tcdefs.h" +%s)}"
		NOSTRIP=1
		NOTEST=1
		VERBOSE=1
		CC="$(tc-getCC)"
		CXX="$(tc-getCXX)"
		AR="$(tc-getAR)"
		RANLIB="$(tc-getRANLIB)"
		TC_EXTRA_CFLAGS="${CFLAGS}"
		TC_EXTRA_CXXFLAGS="${CXXFLAGS}"
		TC_EXTRA_LFLAGS="${LDFLAGS}"
		WX_CONFIG="${WX_CONFIG}"
		$(usex X "" "NOGUI=1")
		$(usex asm "" "NOASM=1")
		$(usex cpu_flags_x86_sse2 "" "NOSSE2=1")
		$(usex cpu_flags_x86_sse4_1 "SSE41=1" "")
		$(usex cpu_flags_x86_ssse3 "SSSE3=1" "")
	)

	emake "${myemakeargs[@]}"
}

src_test() {
	./Main/veracrypt --text --test || die "tests failed"
}

src_install() {
	local DOCS=( Readme.txt )

	dobin Main/veracrypt
	if use doc; then
		DOCS+=( "${S}"/../doc/EFI-DCS )
		docompress -x /usr/share/doc/${PF}/EFI-DCS
		HTML_DOCS=( "${S}"/../doc/html/. )
	fi
	einstalldocs

	newinitd "${FILESDIR}"/veracrypt.init veracrypt

	if use X; then
		local s
		for s in 16 48 128 256; do
			newicon -s ${s} Resources/Icons/VeraCrypt-${s}x${s}.xpm veracrypt.xpm
		done
		make_desktop_entry veracrypt "VeraCrypt" veracrypt "Utility;Security"
	fi

	pax-mark -m "${ED}"/usr/bin/veracrypt
}

pkg_postinst() {
	ewarn "VeraCrypt has a very restrictive license. Please be explicitly aware"
	ewarn "of the limitations on redistribution of binaries or modified source."

	if ver_replacing -lt "1.26.7"; then
		ewarn "Starting with 1.26.7, TrueCrypt volumes are no longer supported."
		ewarn "Please explore alternatives such as dm-crypt to mount truecrypt volumes."
		ewarn "Moreover, support for RIPEMD160 and GOST89 is dropped."
		ewarn "Volumes using these algoritms will no longer mount."
	fi
}
