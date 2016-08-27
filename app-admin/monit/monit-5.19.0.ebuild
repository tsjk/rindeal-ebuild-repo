# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit pam systemd

DESCRIPTION="Utility for monitoring and managing daemons or similar programs"
HOMEPAGE="https://mmonit.com/monit/"
LICENSE="AGPL-3"

SLOT="0"
SRC_URI="https://mmonit.com/monit/dist/${P}.tar.gz"

KEYWORDS="~amd64 ~arm"
IUSE="libressl pam ssl"

CDEPEND="
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)"
DEPEND="${CDEPEND}
	sys-devel/flex
	sys-devel/bison
	pam? ( virtual/pam )"
RDEPEND="${CDEPEND}"

src_configure() {
	local econf_args=(
		$(use_with ssl)
		$(use_with pam)
	)
	econf "${econf_args[@]}"
}

src_install() {
	default

	# default config file
	insinto /etc
	insopts -m600
	doins monitrc

	systemd_dounit "${FILESDIR}"/${PN}.service

	use pam && newpamd "${FILESDIR}"/${PN}.pamd ${PN}
}
