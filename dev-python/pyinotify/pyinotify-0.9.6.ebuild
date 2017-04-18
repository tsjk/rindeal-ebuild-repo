# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:seb-m"

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy pypy3 )
PYTHON_REQ_USE="threads(+)"

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Python module used for monitoring filesystems events"
HOMEPAGE="${GH_HOMEPAGE} https://pypi.python.org/pypi/pyinotify"
LICENSE="MIT"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( examples )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_install_all() {
	use examples && local EXAMPLES=( python2/examples/. python3/examples/. )

	distutils-r1_python_install_all
}
