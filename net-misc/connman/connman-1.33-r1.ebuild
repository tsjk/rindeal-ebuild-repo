# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="kernel:network/"

inherit git-hosting
inherit autotools
inherit systemd

DESCRIPTION="Provides a daemon for managing internet connections"
HOMEPAGE="https://01.org/connman ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	doc debug examples tools

	## HW
	hh2serial-gps bluetooth +ethernet +wifi
	l2tp
	ofono
	openvpn
	openconnect
	pptp
	policykit

	vpnc

	wispr
)

CDEPEND_A=(
	">=dev-libs/glib-2.16"
	">=sys-apps/dbus-1.2.24"
	">=net-firewall/iptables-1.4.8"
	"bluetooth? ( net-wireless/bluez )"
	"l2tp? ( net-dialup/xl2tpd )"
	"ofono? ( net-misc/ofono )"
	"openconnect? ( net-vpn/openconnect )"
	"openvpn? ( net-vpn/openvpn )"
	"policykit? ( sys-auth/polkit )"
	"pptp? ( net-dialup/pptpclient )"
	"vpnc? ( net-vpn/vpnc )"
	"wifi? ( >=net-wireless/wpa_supplicant-2.0[dbus] )"
	"wispr? ( net-libs/gnutls )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=sys-kernel/linux-headers-2.6.39"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

PATCHES=(
	"${FILESDIR}/${PN}-1.31-xtables.patch"
	"${FILESDIR}/${PN}-1.33-polkit-configure-check-fix.patch"
	"${FILESDIR}/${PN}-1.33-resolv-conf-overwrite.patch"
)

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--localstatedir=/var

		--disable-optimization
		$(use_enable debug)
# 		--enable-pie
		$(use_enable hh2serial-gps{,} builtin)
		$(use_enable openconnect{,} builtin)

		--with-systemdunitdir=$(systemd_get_systemunitdir)
		--with-tmpfilesdir=${EPRIFEX}/usr/lib/tmpfiles.d
		--enable-client
		--enable-datafiles
		--enable-loopback=builtin
		$(use_enable examples test)
		$(use_enable ethernet{,} builtin)
		$(use_enable wifi{,} builtin)
		$(use_enable bluetooth{,} builtin)
		$(use_enable l2tp{,} builtin)
		$(use_enable ofono{,} builtin)

		$(use_enable openvpn{,} builtin)
		$(use_enable policykit polkit builtin)
		$(use_enable pptp{,} builtin)
		$(use_enable vpnc{,} builtin)
		$(use_enable wispr{,} builtin)

		$(use_enable tools)
		--disable-iospm
	)

	econf "${my_econf_args[@]}"
}

src_install() {
	default
	dobin client/connmanctl

	use doc && dodoc doc/*.txt

	keepdir /usr/lib/${PN}/scripts
	keepdir /var/lib/${PN}
}
