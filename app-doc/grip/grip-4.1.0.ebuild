# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_{6,7} pypy{,3} python3_{3,4,5} )

inherit distutils-r1 python-r1

DESCRIPTION="Preview GitHub Markdown files like Readme locally before committing them."
HOMEPAGE="https://github.com/joeyespo/grip"
LICENSE="MIT"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

RESTRICT="mirror"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/docopt-0.6.2
	>=dev-python/flask-0.10.1
	>=dev-python/markdown-2.5.1
	>=dev-python/pygments-1.6
	>=dev-python/requests-2.4.1
	>=dev-python/path-and-address-1.0.0
"
