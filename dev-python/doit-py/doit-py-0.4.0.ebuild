# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:pydoit"

PYTHON_COMPAT=( python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="doit tasks for python stuff"
HOMEPAGE="https://pythonhosted.org/doit-py ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc test )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"test? ("
		"dev-python/pytest[${PYTHON_USEDEP}]"
		"dev-python/coverage[${PYTHON_USEDEP}]"
		"virtual/python-singledispatch[${PYTHON_USEDEP}]"
		"app-text/hunspell"
	")"
	"doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/configclass[${PYTHON_USEDEP}]"
)
PDEPEND_A=(
	# cyclic dep
	"dev-python/doit[${PYTHON_USEDEP}]"
)

inherit arrays

python_compile_all() {
	use doc && emake -C doc html
}

python_test() {
	py.test || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/_build/html/. )

	distutils-r1_python_install_all
}
