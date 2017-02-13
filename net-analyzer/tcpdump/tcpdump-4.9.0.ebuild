# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/the-${PN}-group"
GH_REF="${PN}-${PV}"

inherit flag-o-matic
inherit toolchain-funcs
inherit user
inherit git-hosting

DESCRIPTION="Tool for network monitoring and data acquisition"
HOMEPAGE="http://www.tcpdump.org/ ${GH_HOMEPAGE}"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="+drop-root smi ssl samba suid test"

CDEPEND="
	net-libs/libpcap

	drop-root? ( sys-libs/libcap-ng )
	smi? ( net-libs/libsmi )
	ssl? ( dev-libs/openssl:0 )
"
DEPEND="${CDEPEND}
	drop-root? ( virtual/pkgconfig )
	test? (
		|| (
			app-arch/sharutils
			sys-freebsd/freebsd-ubin )
		dev-lang/perl
	)
"
RDEPEND="${CDEPEND}"

src_configure() {
	if use drop-root ; then
		append-cppflags -DHAVE_CAP_NG_H
		export LIBS=$( $(tc-getPKG_CONFIG) --libs libcap-ng )
	fi

	local myeconfargs=(
		$(use_enable samba smb)
		$(use_with drop-root chroot '')
		$(use_with smi)
		$(use_with ssl crypto "${EPREFIX}/usr")
		$(usex drop-root --with-user="${PN}" '')
	)
	econf "${myeconfargs[@]}"
}

src_test() {
	if (( EUID != 0 )) || ! use drop-root ; then
		sed -i -e '/^\(espudp1\|eapon1\)/d;' tests/TESTLIST || die
		emake check
	else
		ewarn "Tests skipped!"
		ewarn "If you want to run the test suite, make sure you either"
		ewarn "set FEATURES=userpriv or set USE=-drop-root"
	fi
}

src_install() {
	dosbin "${PN}"
	doman "${PN}.1"

	dodoc *.awk
	einstalldocs

	if use suid ; then
		fowners root:${PN} "/usr/sbin/${PN}"
		fperms 4110 "/usr/sbin/${PN}"
	fi
}

pkg_preinst() {
	if use drop-root || use suid ; then
		enewgroup ${PN}
		enewuser ${PN} -1 -1 -1 ${PN}
	fi
}

pkg_postinst() {
	use suid && elog "To let normal users run '${PN}' add them into '${PN}' group."
}
