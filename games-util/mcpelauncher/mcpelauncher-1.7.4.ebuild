# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit git-r3 cmake toolchain-funcs flag-o-matic

DESCRIPTION="Minecraft Bedrock Launcher for Linux"
HOMEPAGE="https://github.com/minecraft-linux/mcpelauncher-manifest"
EGIT_REPO_URI="https://github.com/minecraft-linux/mcpelauncher-manifest.git"

if ver_test "${PV}" -eq 9999; then
	EGIT_BRANCH="qt6"
else
	EGIT_COMMIT="v${PV}-qt6"
fi

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"

DEPEND="
	dev-cpp/nlohmann_json
	dev-libs/libevdev
	dev-libs/libuv
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtwebengine:6
	llvm-core/clang:*
	llvm-core/llvm:*
	media-libs/libpng
	media-libs/libsdl3
	net-misc/curl
	sys-libs/zlib
	x11-libs/libXi
"
RDEPEND="
	${DEPEND}
	games-util/mcpelauncher-ui-qt
"

QA_PREBUILT="usr/share/mcpelauncher/lib/*"
QA_SONAME="usr/share/mcpelauncher/lib/*"

src_prepare() {
	cmake_src_prepare

	eapply -p1 "${FILESDIR}/0001-Use-system-nlohmann_json.patch"
	eapply -p1 "${FILESDIR}/0001-Make-compatible-with-nlohmann_json-3.12.0.patch"
}

src_configure() {
	elog "Forcing Toolchain to Clang/LLD"
	AR=llvm-ar
	CC=${CHOST}-clang
	CXX=${CHOST}-clang++
	NM=llvm-nm
	RANLIB=llvm-ranlib

	append-cxxflags "-DNDEBUG"
	append-ldflags "-fuse-ld=lld"
	strip-unsupported-flags
	append-flags "-D_FORTIFY_SOURCE=0"

	export HOST_CC="$(tc-getBUILD_CC)"
	export HOST_CXX="$(tc-getBUILD_CXX)"
	tc-export CC CXX LD AR NM OBJDUMP RANLIB PKG_CONFIG

	local mycmakeargs=(
		-DUSE_OWN_CURL=OFF
		-DBUILD_SHARED_LIBS=OFF
		-DENABLE_DEV_PATHS=OFF
		-DGAMEWINDOW_SYSTEM=SDL3
		-DSDL3_VENDORED=OFF
		-Wno-dev
	)

	cmake_src_configure
}
