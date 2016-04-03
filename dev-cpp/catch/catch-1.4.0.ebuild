# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="A modern, C++-native, header-only, framework for unit-tests, TDD and BDD"
HOMEPAGE="https://github.com/philsquared/Catch"
LICENSE="Boost-1.0"
SRC_URI="https://github.com/philsquared/Catch/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""

S="${WORKDIR}/Catch-${PV}"

src_install() {
	insinto	'/usr/include/catch'
	doins	'single_include/catch.hpp'

	einstalldocs
}
