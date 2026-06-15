# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 git-r3

DESCRIPTION="A modern, simplified rewrite of Gentoo's flaggie"
HOMEPAGE="https://github.com/Gur0v/flagger"
EGIT_REPO_URI="https://github.com/Gur0v/flagger.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

IUSE="+gentoopm"

RDEPEND="
	gentoopm? ( >=app-portage/gentoopm-0.5.0[${PYTHON_USEDEP}] )
"

EPYTEST_XDIST=1

distutils_enable_tests pytest
