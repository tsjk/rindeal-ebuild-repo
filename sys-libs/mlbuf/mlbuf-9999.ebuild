# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/adsr"

inherit git-hosting

DESCRIPTION="Multiline buffer library"
# no licence so far - https://github.com/adsr/mle/issues/2
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="+static-libs"

CDEPEND="
	dev-libs/libpcre:3
	dev-libs/uthash"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

src_prepare() {
	default

	# use global utlist.h instead of bundled copy
	sed -r -e 's|(#include *)"utlist.h"|\1<utlist.h>|g' -i -- *.{c,h} || die

	sed \
		-e '/CFLAGS/ s| -g||' \
		-e "/LDLIBS/ s| -lpcre| $(pkg-config --libs libpcre)|" \
		-i Makefile || die
}

src_install() {
	dolib.so lib${PN}.so
	use static-libs && \
		dolib.a lib${PN}.a

	doheader "${PN}.h"
}
