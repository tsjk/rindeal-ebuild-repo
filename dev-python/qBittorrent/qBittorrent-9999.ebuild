# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:v1k45:python-qBittorrent"
PYTHON_COMPAT=( python2_7 )

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit distutils-r1

DESCRIPTION="Python wrapper for qBittorrent Web API (for versions above v3.1.x)"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/requests[${PYTHON_USEDEP}]"
)

inherit arrays
