# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools eutils

DESCRIPTION="BitTorrent Client using libtorrent"
HOMEPAGE="https://rakshasa.github.io/rtorrent/"
LICENSE="GPL-2"
SRC_URI="https://github.com/rakshasa/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
SLOT="0"
KEYWORDS="amd64 arm ~hppa ~ia64 ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris"
IUSE="daemon debug ipv6 selinux test xmlrpc fallocate"

COMMON_DEPEND="~net-libs/libtorrent-0.13.${PV##*.}
	>=dev-libs/libsigc++-2.2.2:2
	>=net-misc/curl-7.19.1
	sys-libs/ncurses:0=
	xmlrpc? ( dev-libs/xmlrpc-c )"
RDEPEND="${COMMON_DEPEND}
	daemon? ( app-misc/screen )
	selinux? ( sec-policy/selinux-rtorrent )
"
DEPEND="${COMMON_DEPEND}
	dev-util/cppunit
	virtual/pkgconfig"

DOCS=( doc/rtorrent.rc )

src_prepare() {
	default

	# bug #358271
	epatch \
		"${FILESDIR}"/${PN}-0.9.1-ncurses.patch \
		"${FILESDIR}"/${PN}-0.9.4-tinfo.patch

	# use wiki, man pages are outdated - https://github.com/rakshasa/rtorrent/issues/332

	eautoreconf
}

src_configure() {
	default

	# configure needs bash or script bombs out on some null shift, bug #291229
	CONFIG_SHELL=${BASH} econf \
		--disable-dependency-tracking \
		$(use_enable debug) \
		$(use_enable ipv6) \
		$(use_with xmlrpc xmlrpc-c)
		$(use_with fallocate posix-fallocate)
}

src_install() {
	default

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.init" $PN
		newconfd "${FILESDIR}/${PN}.conf" $PN
	fi
}
