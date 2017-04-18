# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:hMatoba:Piexif"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1
inherit git-hosting

DESCRIPTION="Exif manipulation in pure python"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( test )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
# 	"test? ("
# 		"~dev-python/pillow-4.0.0[${PYTHON_USEDEP}]" # TODO: gentoo repos have only old version
# 	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

RESTRICT+=" test"

inherit arrays

python_test() {
	esetup.py test
}
