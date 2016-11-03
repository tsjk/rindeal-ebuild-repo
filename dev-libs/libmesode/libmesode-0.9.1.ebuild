# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/boothj5"

inherit git-hosting
# functions: eautoreconf
inherit autotools
# functions: prune_libtool_files
inherit eutils

DESCRIPTION="Fork of libstrophe for use with Profanity XMPP Client"
LICENSE="MIT GPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE_A=( doc static-libs +tls )

CDEPEND_A=(
	# pkg-config: 'expat >= 2.0.0'
	">=dev-libs/expat-2.0.0"
	"tls? ("
		# pkg modules: openssl
		"dev-libs/openssl:0="
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-devel/libtool"
	"virtual/pkgconfig"
	"doc? ( app-doc/doxygen )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	sed -e '/^AM_CFLAGS/ s| -g||' -i Makefile.am || die

	eautoreconf
}

src_compile() {
	default

	use doc && { doxygen || die ; }
}

src_configure() {
	local myeconfargs=(
		$(use_enable static-libs static)
		$(use_enable tls)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	prune_libtool_files

	if use doc ; then
		docinto html
		dodoc -r docs/html/*
	fi
}
