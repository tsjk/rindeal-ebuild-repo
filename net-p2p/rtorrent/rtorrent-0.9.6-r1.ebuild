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
KEYWORDS="~amd64 ~arm"
IUSE="daemon debug ipv6 selinux test xmlrpc fallocate unicode"

COMMON_DEPEND="
	~net-libs/libtorrent-0.13.${PV##*.}
	>=dev-libs/libsigc++-2.2.2:2
	>=net-misc/curl-7.19.1
	sys-libs/ncurses:0=
	xmlrpc? ( dev-libs/xmlrpc-c )"
RDEPEND="${COMMON_DEPEND}
	daemon? ( app-misc/screen )
	selinux? ( sec-policy/selinux-rtorrent )
	~sys-apps/openrc-rfl-0.0.5
"
DEPEND="${COMMON_DEPEND}
	dev-util/cppunit
	virtual/pkgconfig
"

src_prepare() {
	# bug #358271
	PATCHES=( "${FILESDIR}/${PN}-"{0.9.1-ncurses.patch,0.9.4-tinfo.patch} )

	default
	eautoreconf
}

src_configure() {
	local econf_args=(
		--disable-dependency-tracking
		$(use_enable debug)
		$(use_enable ipv6)
		$(use_with xmlrpc xmlrpc-c)
		$(use_with fallocate posix-fallocate)
		$(use_with unicode ncursesw)
	)

	# configure needs bash or script bombs out on some null shift, bug #291229
	CONFIG_SHELL=${BASH} econf "${econf_args[@]}"
}

src_install() {
	DOCS=( doc/rtorrent.rc )
	default

	# rather use wiki, man pages are outdated - https://github.com/rakshasa/rtorrent/issues/332
	doman "${FILESDIR}/${PN}.1"

	if use daemon; then
		local daemon_name="${PN}d"

		local args=(
			-e "s|@@EROOT@@|${EROOT}|g"
			-e "s|@@RTORRENT_BIN@@|${EROOT}usr/bin/rtorrent|g"
		)
		sed -r "${args[@]}" -- "${FILESDIR}/${daemon_name}.init.in" > "${T}/${daemon_name}.init" || die
		newinitd "${T}/${daemon_name}.init" "${daemon_name}"
		newconfd "${FILESDIR}/${daemon_name}.conf" "${daemon_name}"
	fi
}
