# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# TODO: `The C extension could not be compiled, speedups are not enabled. Plain-Python build succeeded.`

EAPI=6
inherit rindeal

GH_RN="github:getlogbook:logbook"

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Logging replacement for Python"
HOMEPAGE="${GH_HOMEPAGE} https://pypi.python.org/pypi/Logbook"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc test )

# DISTUTILS_IN_SOURCE_BUILD=1

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"test? ( dev-python/pytest[${PYTHON_USEDEP}] )"
	"doc? ( >=dev-python/sphinx-1.1.3-r3[${PYTHON_USEDEP}] )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/redis-py[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	# Delete test file requiring local connection to redis server
	erm tests/test_queues.py

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	py.test tests || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	use doc && HTML_DOCS=( docs/_build/html/. )

	distutils-r1_python_install_all
}
