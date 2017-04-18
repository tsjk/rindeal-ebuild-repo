# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:tibonihoo"
GH_REF="release_${PN^}-${PV}"

PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Fat-free DIY Python plugin management toolkit"
HOMEPAGE="http://yapsy.sourceforge.net/ ${GH_HOMEPAGE}"
LICENSE="BSD"

SLOT="0"
MY_P="Yapsy-${PV}"
# SRC_URI="mirror://sourceforge/yapsy/${MY_P}/${MY_P}.tar.gz"

KEYWORDS="amd64 arm arm64"
IUSE_A=( doc )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

OLD_S="${S}"
S="${S}/package"

python_prepare_all() {
	# Disable erroneous test
	sed -e 's:test_default_plugins_place_is_parent_dir:_&:' \
		-i test/test_PluginFileLocator.py || die
	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C doc html
}

python_test() {
	esetup.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/_build/html/. )

	distutils-r1_python_install_all
}
