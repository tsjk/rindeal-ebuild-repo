# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:python"
GH_REF="v${PV}"

PYTHON_COMPAT=( python3_{4,5,6} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Optional static typing for Python"
HOMEPAGE="http://www.mypy-lang.org/ ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc test"

DEPEND="
	test? ( dev-python/flake8[${PYTHON_USEDEP}] )
	doc? (
		dev-python/sphinx[${PYTHON_USEDEP}]
		dev-python/sphinx_rtd_theme[${PYTHON_USEDEP}]
	)
"
RDEPEND_A=(
	"dev-python/typeshed"
	">=dev-python/typed-ast-1.0.4[${PYTHON_USEDEP}]"
	"<dev-python/typed-ast-1.1.0[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	sed -r -e "/typeshed_dir = os.path/ s| = .*|= os.path.join('/', '${EPREFIX}', 'usr', 'share', 'typeshed')|" \
		-i -- "${PN}/build.py" || die

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	local PYTHONPATH="${PWD}"

	"${PYTHON}" runtests.py || die "tests failed under ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/build/html/. )

	dosym /usr/share/typeshed /usr/lib/${PN}/typeshed

	distutils-r1_python_install_all
}
