# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3

DESCRIPTION="A tool for creating an amalgamation from C and C++ sources"
HOMEPAGE="https://github.com/rindeal/Amalgamate"
LICENSE="MIT"
EGIT_REPO_URI="https://github.com/rindeal/Amalgamate.git"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	dobin "${PN}"
	einstalldocs
}
