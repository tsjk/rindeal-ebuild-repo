# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils flag-o-matic toolchain-funcs

MY_P=${P/_beta/-b}

DESCRIPTION="Multipurpose relay (SOcket CAT)"
HOMEPAGE="http://www.dest-unreach.org/socat/"
LICENSE="GPL-2"
SRC_URI="http://www.dest-unreach.org/socat/download/${MY_P}.tar.bz2"

SLOT="0"
KEYWORDS="amd64 arm"
IUSE="ssl readline ipv6 tcpd"
RESTRICT="test"

DEPEND="
	ssl? ( dev-libs/openssl:0= )
	readline? ( sys-libs/readline:= )
	tcpd? ( sys-apps/tcp-wrappers )
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/${PN}-1.7.3.0-filan-build.patch"
	"${FILESDIR}/${PN}-1.7.3.1-ptrdiff_t-is-defined-in-stddef.h.patch" #576270
)

src_configure() {
	filter-flags '-Wno-error*' #293324
	tc-export AR
	local econf_args=(
		$(use_enable ssl openssl)
		$(use_enable readline)
		$(use_enable ipv6 ip6)
		$(use_enable tcpd libwrap)
	)
	econf "${econf_args[@]}"
}

src_install() {
	DOCS=( BUGREPORTS CHANGES DEVELOPMENT EXAMPLES FAQ FILES PORTING README SECURITY )
	HTML_DOCS=( doc/*.html doc/*.css )
	default
}
