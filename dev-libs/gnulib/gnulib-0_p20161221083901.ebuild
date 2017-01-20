# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_REF="3a0b7b74982f44c735f4cfc2dccf538c3c4ef9e2"

DESCRIPTION="Gnulib is a library of common routines intended to be shared at the source level"
HOMEPAGE="https://www.gnu.org/software/gnulib"
LICENSE="GPL-2"

MY_PN="${PN}-${GH_REF}"
SLOT="0"
SRC_URI="http://git.savannah.gnu.org/cgit/${PN}.git/snapshot/${MY_PN}.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc"

S="${WORKDIR}/${MY_PN}"

src_compile() {
	if use doc ; then
		emake -C doc info html
	fi
}

src_install() {
	dodoc README ChangeLog

	mkdir -p "${ED}/usr/share/${PN}" || die
	cp -a \
        build-aux \
        doc \
        lib \
        m4 \
        modules \
        tests \
        top \
        ChangeLog \
        "${ED}/usr/share/${PN}" || die
# 	doins ChangeLog # parsed by `gnulib-tool --version`

	# install the real script
	exeinto "/usr/share/${PN}"
	doexe gnulib-tool

	# create and install the wrapper
	dosym "/usr/share/${PN}/gnulib-tool" "/usr/bin/gnulib-tool"
}
