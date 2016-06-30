# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit pam systemd

DESCRIPTION="Utility for monitoring and managing daemons or similar programs"
HOMEPAGE="https://mmonit.com/monit/"
LICENSE="AGPL-3"

SLOT="0"

SRC_URI="https://mmonit.com/monit/dist/${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~x86"
IUSE="libressl pam ssl"

RDEPEND="
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)"
DEPEND="${RDEPEND}
	sys-devel/flex
	sys-devel/bison
	pam? ( virtual/pam )"

src_configure() {
	local econf_args=(
		$(use_with ssl)
		$(use_with pam)
	)
	econf "${econf_args[@]}"
}

src_install() {
	default

	insinto /etc
	insopts -m600
	doins monitrc

	newinitd "${FILESDIR}"/monit.initd-5.0-r1 monit
	systemd_dounit "${FILESDIR}"/${PN}.service

	use pam && newpamd "${FILESDIR}"/${PN}.pamd ${PN}
}
