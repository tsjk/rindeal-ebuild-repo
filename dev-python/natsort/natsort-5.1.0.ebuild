# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:SethMMorton"

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Natural sorting for Python"
HOMEPAGE="${GH_HOMEPAGE} https://pypi.python.org/pypi/natsort"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="test"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"test? ("
		"dev-python/pytest[${PYTHON_USEDEP}]"
		"dev-python/hypothesis[${PYTHON_USEDEP}]"
		"virtual/python-pathlib[${PYTHON_USEDEP}]"
		"dev-python/pytest-cov[${PYTHON_USEDEP}]"
		"$(python_gen_cond_dep 'dev-python/mock[${PYTHON_USEDEP}]' python2_7 pypy)"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

RESTRICT+=" test"

python_test() {
	py.test || die "Tests failed under ${EPYTHON}"
}
