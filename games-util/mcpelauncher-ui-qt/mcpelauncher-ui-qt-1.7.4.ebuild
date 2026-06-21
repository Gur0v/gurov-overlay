# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

inherit git-r3 cmake flag-o-matic xdg-utils

DESCRIPTION="Minecraft Bedrock Launcher for Linux (UI)"
HOMEPAGE="https://github.com/minecraft-linux/mcpelauncher-ui-manifest"
EGIT_REPO_URI="https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git"

if ver_test "${PV}" -eq 9999; then
	EGIT_BRANCH="qt6"
else
	EGIT_COMMIT="v${PV}-qt6"
fi

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="network-sandbox"

DEPEND="
	dev-libs/libzip
	dev-libs/protobuf:=
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtsvg:6
	dev-qt/qtwebengine:6
"
RDEPEND="
	${DEPEND}
"

PATCHES=(
	"${FILESDIR}/0001-ext-glfw.cmake-Workaround-cmake-warning.patch"
)

src_configure() {
	filter-flags "-flto*"

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DLAUNCHER_ENABLE_GLFW=OFF
		-Wno-dev
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
