# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:python:${PN//-/_}"

PYTHON_COMPAT=( python3_{4,5,6} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Fork of Python 2 and 3 ast modules with type comment support"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc test"
