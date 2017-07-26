# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:adsr"
GH_REF="v${PV}"
EGIT_SUBMODULES=() # no submodules please

inherit git-hosting

DESCRIPTION="Small but powerful console text editor written in C"
# - Troy D. Hanson's code is licenced under BSD-2 without the second clause
# - other code is Apache-2.0
LICENSE="Apache-2.0 BSD-1"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE=""

CDEPEND=""
DEPEND="${CDEPEND}
	sys-libs/mlbuf:0
	sys-libs/termbox:0"
RDEPEND="${CDEPEND}"

REQUIRED_USE=""
RESTRICT+=""

src_prepare() {
	default

	local sedargs=(
		# flags
		-e '/mle_cflags/ s| -g||g'

		# libpcre
		-e "/mle_ldlibs/ s| -lpcre| $(pkg-config --libs libpcre)|"

		# static lib{mlbuf,termbox}
		-e '/mle_cflags/ s@-I[^ ]*(mlbuf|termbox)[^ ]*@@g'
		-e '/^mle:/ s@[^ \t]*lib(mlbuf|termbox)\.a@@g'
		-e '/\$\(CC\)/ s@[^ ]*(lib(mlbuf|termbox)\.a)@-l\2@g'
	)
	sed -r "${sedargs[@]}" -i Makefile || die
}

src_install() {
	dobin "${PN}"
	einstalldocs
}
