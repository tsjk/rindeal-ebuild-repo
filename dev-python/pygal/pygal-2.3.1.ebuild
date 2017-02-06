# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/Kozea"

PYTHON_COMPAT=( python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="A python SVG charts generator"
HOMEPAGE="http://pygal.org/ ${GH_HOMEPAGE}"
LICENSE="LGPL-3+"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/lxml[${PYTHON_USEDEP}]"
	"media-gfx/cairosvg[${PYTHON_USEDEP}]"
)

inherit arrays

python_install_all() {
	distutils-r1_python_install_all

	newdoc docs/changelog.rst CHANGELOG
}
