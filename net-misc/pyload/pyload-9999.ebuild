# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github"
EGIT_BRANCH="master" # defaults to `stable`

PYTHON_COMPAT=( python2_7 )

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit distutils-r1

DESCRIPTION="Example package"
HOMEPAGE="https://pyload.net/ ${GH_HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

[[ "${PV}" != *9999* ]] && KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	default

	sed -r -e 's|([^\.])(path.join)|\1os.\2|' -i -- setup.py || die

	# `PROJECT_DIR=~/.pyload`
# 	sed -e "/^PROJECT_DIR/ s|.*|PROJECT_DIR = '${S}'|" -i -- setup.py || die
	sed -e "/^PROJECT_DIR/ i os.chdir('${S}')" -i -- setup.py || die

	distutils-r1_src_prepare
}
