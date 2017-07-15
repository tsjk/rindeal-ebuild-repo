# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1
inherit git-hosting

DESCRIPTION="Python library to access the Github API v3"
LICENSE="LGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="test"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/pyjwt[${PYTHON_USEDEP}]"
)

inherit arrays

src_prepare() {
	if ! use test ; then
		sed -e '/"github.tests"/d' -i -- setup.py || die
		sed -e '/"github": \["tests/d' -i -- setup.py || die
	fi

	distutils-r1_src_prepare
}

python_test() {
	esetup.py test
}
