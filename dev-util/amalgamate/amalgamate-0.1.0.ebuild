# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/rindeal/Amalgamate"

inherit git-hosting

DESCRIPTION="A tool for creating an amalgamation from C and C++ sources"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm"

src_install() {
	dobin ${PN}
	doman ${PN}.1

	einstalldocs
}
