# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/schettino72"

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Python to class to hold configuration values"
LICENSE="MIT"

SLOT="0"

KEYWORDS="amd64 arm arm64"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=dev-python/mergedict-0.2.0[${PYTHON_USEDEP}]"
)

inherit arrays
