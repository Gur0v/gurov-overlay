# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="A library for working with .desktop files"
HOMEPAGE="https://pypi.org/project/desktop-entry-lib/"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"
