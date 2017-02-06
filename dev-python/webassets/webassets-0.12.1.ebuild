# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/miracle2k"

PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Asset management for Python web development"
LICENSE="BSD-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( test )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"test? ("
		"dev-python/pytest[${PYTHON_USEDEP}]"
		"dev-python/nose[${PYTHON_USEDEP}]"
		"dev-python/mock[${PYTHON_USEDEP}]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_prepare_all() {
	# webassets wants /usr/bin/babel from babeljs,
	# but we have only one from openbabel
	# ... and we don't have postcss
	sed -i \
		-e 's|\(TestBabel\)|No\1|' \
		-e 's|\(TestAutoprefixer6Filter\)|No\1|' \
		tests/test_filters.py || die

	distutils-r1_python_prepare_all
}

python_test() {
	py.test -v || die
}
