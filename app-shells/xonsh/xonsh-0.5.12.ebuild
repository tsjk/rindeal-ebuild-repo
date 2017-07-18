# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github"

PYTHON_COMPAT=( python3_{4,5,6} )

inherit git-hosting
inherit distutils-r1
inherit eutils

DESCRIPTION="Python-powered, cross-platform, Unix-gazing shell"
HOMEPAGE="
	${GH_HOMEPAGE}
	http://xonsh.readthedocs.org/
	http://pypi.python.org/pypi/xonsh"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="test"

CDEPEND_A=(
	"dev-python/ply[${PYTHON_USEDEP}]"
	"dev-python/pygments[${PYTHON_USEDEP}]"
)
DEPEND=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"test? ("
		"dev-python/nose[${PYTHON_USEDEP}]"
	")"
)

inherit arrays

python_test() {
	nosetests --verbose || die
}

pkg_postinst() {
	elog "Optional features"
	optfeature "Jupyter kernel support" dev-python/jupyter
	optfeature "Alternative to readline backend" dev-python/prompt_toolkit
}
