# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Nigel's performance MONitor for CPU, memory, network, disks, etc..."
HOMEPAGE="http://nmon.sourceforge.net/"
LICENSE="GPL-3"
SRC_URI="mirror://sourceforge/${PN}/lmon${PV}.c"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"

RDEPEND="sys-libs/ncurses:0="
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}

src_unpack() {
	cp "${DISTDIR}"/lmon${PV}.c "${S}"/nmon.c || die
}

src_compile() {
	append-cppflags -DJFS -DGETUSER -DLARGEMEM -DX86
	emake CC="$(tc-getCC)" LDLIBS="$( $(tc-getPKG_CONFIG) --libs ncurses) -lm" ${PN}
}

src_install() {
	dobin nmon
}
