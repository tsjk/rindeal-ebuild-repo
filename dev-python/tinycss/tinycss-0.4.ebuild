# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/Kozea"
GH_REF="v${PV}"

PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="A complete yet simple CSS parser for Python"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=(
	"dev-python/lxml[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

RESTRICT+=" test"

inherit arrays

python_test() {
	export TINYCSS_SKIP_SPEEDUPS_TESTS=1
	local test
	for test in ${PN}/tests/test_*.py; do
		py.test $test || die
	done
}

DOCS=( CHANGES README.rst )
