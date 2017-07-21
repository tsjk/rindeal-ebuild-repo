# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:python"

PYTHON_COMPAT=( python2_7 python3_4 pypy{,3} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Type Hints for Python"
HOMEPAGE="${GH_HOMEPAGE} https://docs.python.org/3/library/typing.html"
LICENSE="PSF-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

python_test() {
	cd "${BUILD_DIR}" || die
	if [[ ${EPYTHON} == python2* || ${EPYTHON} == pypy ]]; then
		ecp "${S}"/python2/test_typing.py .
	else
		ecp "${S}"/src/test_typing.py .
	fi

	"${EPYTHON}" test_typing.py || die "tests failed under ${EPYTHON}"
}
