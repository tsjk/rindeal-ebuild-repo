# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="bitbucket/jgehrcke"

PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Child process management and IPC in the context of gevent"
HOMEPAGE="http://gehrcke.de/gipc ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

# requirements in `gdrivefs/resources/requirements.txt`
CDEPEND_A=(
	">=dev-python/gevent-1.1[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays
