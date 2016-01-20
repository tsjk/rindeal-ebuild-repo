# Copyright (C) 2015-2016; Jan Chren <dev.rindeal@outlook.com>
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python3_{3,4})

inherit distutils-r1 python-r1

DESCRIPTION="C++ man pages for Linux, with source from cplusplus.com and cppreference.com"
HOMEPAGE="https://github.com/aitjcize/cppman"
LICENSE="GPL-3"
SRC_URI="mirror://pypi/c/${PN}/${P}.tar.gz"

RESTRICT="mirror"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

RDEPEND="
	sys-apps/groff
	>=dev-python/beautifulsoup-4.0.0
"
