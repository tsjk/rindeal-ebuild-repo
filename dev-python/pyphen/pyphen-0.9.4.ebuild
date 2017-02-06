# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/Kozea/Pyphen"

PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Python module for hyphenation using hunspell dictionaries"
HOMEPAGE="https://github.com/Kozea/Pyphen"
LICENSE="GPL-2+ LGPL-2+ MPL-1.1"

SLOT="0"

KEYWORDS="amd64 arm arm64"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays
