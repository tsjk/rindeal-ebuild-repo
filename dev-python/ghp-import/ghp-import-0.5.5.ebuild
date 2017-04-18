# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:davisp"

PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Copy your docs directly to the gh-pages branch"
LICENSE="tumbolia"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_prepare_all() {
	sed \
		-e '4ifrom codecs import open\n' \
		-e '/LONG_DESC/s/))/), encoding = "utf-8")/' \
		-i setup.py || die

	distutils-r1_python_prepare_all
}
