# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/coleifer"

PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="A small library for extracting rich content from urls"
HOMEPAGE="https://micawber.readthedocs.io ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc examples )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

PATCHES=( "${FILESDIR}"/0.3.2-remove-examples-from-setup.py.patch ) #555250

python_install_all() {
	distutils-r1_python_install_all

	use doc && dodoc -r docs
	use examples && dodoc -r examples/
}
