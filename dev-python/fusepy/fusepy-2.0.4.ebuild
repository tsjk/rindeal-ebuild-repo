# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/terencehonles"
GH_REF="v${PV}"

PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Simple ctypes python bindings for FUSE"
HOMEPAGE="${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE_A=( )

CDEPEND_A=(
	">=sys-fs/fuse-2.6"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	# collision in `fuse.py` file
	"!dev-python/fuse-python[${PYTHON_USEDEP}]"
)

inherit arrays
