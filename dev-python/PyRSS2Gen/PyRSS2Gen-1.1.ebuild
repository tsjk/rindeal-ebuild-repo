# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy )

inherit distutils-r1

DESCRIPTION="RSS feed generator written in Python"
HOMEPAGE="http://www.dalkescientific.com/Python/PyRSS2Gen.html https://pypi.python.org/pypi/PyRSS2Gen"
LICENSE="BSD"

SLOT="0"
SRC_URI="http://www.dalkescientific.com/Python/${P}.tar.gz"

KEYWORDS="amd64 arm arm64"
