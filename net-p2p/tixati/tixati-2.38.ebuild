# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils fdo-mime

DESCRIPTION="Tixati is a New and Powerful P2P System"
HOMEPAGE="https://www.tixati.com"
LICENSE="${PN}" # bundled in the binary, available in menu "About -> License Agreement"

SLOT="0"

src_uri_base="${HOMEPAGE}/download/${P}-1.<ARCH>.manualinstall.tar.gz"
SRC_URI="
	x86?	( ${src_uri_base//<ARCH>/i686} )
	amd64?	( ${src_uri_base//<ARCH>/x86_64} )
"

KEYWORDS="-* ~amd64 ~x86"

RDEPEND="
	sys-apps/dbus:0
	dev-libs/dbus-glib:0
	dev-libs/glib:2
	x11-libs/gtk+:2
	x11-libs/pango:0
	sys-libs/zlib:0
"

RESTRICT="mirror strip"

S="${WORKDIR}/${A%.tar.gz}"

QA_EXECSTACK="usr/bin/${PN}"

src_install() {
	dobin	"$PN"
	doicon	"$PN.png"

	# fix invalid `Categories` value
	sed 's|Internet;||' -i -- "$PN.desktop" || die
	domenu	"$PN.desktop"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
