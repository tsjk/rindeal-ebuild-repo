# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/Xfennec"
GH_REF="v${PV}"

inherit git-hosting

DESCRIPTION="Linux tool to show progress for cp, mv, dd, and virtually any command"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm"

CDEPEND="sys-libs/ncurses:0="
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

src_prepare() {
	default

	sed -e '/CFLAGS/s:-g ::' \
		-e '/^PREFIX / s@=.*@= /usr@' \
		-i Makefile || die
}
