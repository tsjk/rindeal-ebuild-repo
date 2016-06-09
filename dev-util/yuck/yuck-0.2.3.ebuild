# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/hroptatyr"
GH_REF="v${PV}"

inherit git-hosting autotools

DESCRIPTION="Your Umbrella Command Kit, a command line option parser for C"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~x86"

src_prepare() {
	default

	eautoreconf
}
