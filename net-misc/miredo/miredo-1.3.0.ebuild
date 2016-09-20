# Copyright 1999-2014 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="gitlab/rindeal"
EGIT_CLONE_TYPE="shallow"
EGIT_BRANCH="master"

inherit autotools eutils linux-info user git-hosting

DESCRIPTION="Miredo is an open-source Teredo IPv6 tunneling software"
HOMEPAGE="http://www.remlab.net/miredo/ ${HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="amd64 arm"
IUSE="+caps +client nls +assert judy"

RDEPEND="
	sys-devel/gettext
	sys-apps/iproute2
	virtual/udev
	caps? ( sys-libs/libcap )
	judy? ( dev-libs/judy )"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

#tries to connect to external networks (#339180)
RESTRICT+=" test"

CONFIG_CHECK="~IPV6 ~TUN"

src_prepare() {
	default

	# the following step is normally done in `autogen.sh`
	cp -v "${EPREFIX}"/usr/share/gettext/gettext.h "${S}"/include || die

	eautoreconf
}

src_configure() {
	local econf_args=(
		--disable-static
		--enable-miredo-user=miredo
		--with-runstatedir=/run

		$(use_enable assert)
		$(use_with caps libcap)
		$(use_enable client teredo-client)
		$(use_enable nls)
	)
	econf "${econf_args[@]}"
}

src_install() {
	default

	prune_libtool_files

	insinto /etc/miredo
	doins misc/miredo-server.conf
}

pkg_preinst() {
	enewgroup miredo
	enewuser miredo -1 -1 /var/empty miredo
}
