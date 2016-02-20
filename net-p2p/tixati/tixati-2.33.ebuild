# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils fdo-mime

DESCRIPTION="Tixati is a New and Powerful P2P System"
HOMEPAGE="http://www.tixati.com"
LICENSE="$PN" # bundled in the binary, available in menu "About -> License Agreement"

SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="mirror strip"

RDEPEND="
	>=sys-apps/dbus-1.0.2
	>=dev-libs/dbus-glib-0.78
	>=dev-libs/glib-2.16.0:2
	>=x11-libs/gtk+-2.16.0:2
	>=x11-libs/pango-1.14.0
	>=sys-libs/zlib-1.1.4
"

src_uri_base="${HOMEPAGE}/download/${P}-1.<ARCH>.manualinstall.tar.gz"
SRC_URI="
	x86?	( ${src_uri_base/<ARCH>/i686} )
	amd64?	( ${src_uri_base/<ARCH>/x86_64} )
"

S="$WORKDIR/${A/.tar.gz}"

src_install() {
	dobin	"$PN"
	doicon	"$PN.png"
	domenu	"$PN.desktop"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
