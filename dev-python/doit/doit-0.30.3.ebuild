# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/pydoit"

PYTHON_COMPAT=( python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Task management & automation tool"
HOMEPAGE="http://pydoit.org/ ${GH_HOMEPAGE} https://pypi.python.org/pypi/doit"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc test )

CDEPEND_A=(
	"dev-python/pyinotify[${PYTHON_USEDEP}]"
	"dev-python/six[${PYTHON_USEDEP}]"
	">=dev-python/doit-py-0.3.0[${PYTHON_USEDEP}]"
	"$(python_gen_cond_dep 'dev-python/configparser[${PYTHON_USEDEP}]' python2_7 pypy)"
	"doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )"
)
DEPEND=( "${CDEPEND_A[@]}"
	"test? ("
		"dev-python/pytest[${PYTHON_USEDEP}]"
		"dev-python/mock[${PYTHON_USEDEP}]"
		"dev-python/pyflakes[${PYTHON_USEDEP}]"
		"dev-python/coverage[${PYTHON_USEDEP}]"
		"dev-python/cloudpickle[${PYTHON_USEDEP}]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

RESTRICT="test" # can't work as it imports nonexistant modules from coverage

inherit arrays

# # Required for test phase
# DISTUTILS_IN_SOURCE_BUILD=1

python_prepare_all() {
	# Disable test failing due to impact on PATH run in a sandbox
	sed -e s':test_target:_&:' -i tests/test_cmd_strace.py || die

	# Test requires connection to an absent database
	sed -e s':testIgnoreAll:_&:' -i tests/test_cmd_ignore.py || die

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C doc html
}

python_test() {
	local -x TMPDIR="${T}"

	py.test || die "Tests failed under ${EPYTHON}"
}

src_install() {
	use doc && HTML_DOCS=( doc/_build/html/. )

	distutils-r1_src_install
}
