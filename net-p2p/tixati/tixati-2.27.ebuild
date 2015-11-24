# Copyright (C) 2015; Jan Chren <dev.rindeal@outlook.com>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils fdo-mime

DESCRIPTION="Tixati is a New and Powerful P2P System"
HOMEPAGE="http://www.tixati.com"
LICENSE="$PN"

SLOT="0"
KEYWORDS="-* ~amd64 ~x86"

RDEPEND="
    >=sys-apps/dbus-1.0.2
    >=dev-libs/dbus-glib-0.78
    >=dev-libs/glib-2.16.0:2
    >=x11-libs/gtk+-2.16.0:2
    >=x11-libs/pango-1.14.0
    >=sys-libs/zlib-1.1.4
"

RESTRICT="mirror strip"

src_uri_base="$HOMEPAGE/download"
pkg_name_muster="$PN-$PV-1.<ARCH>.manualinstall"
SRC_URI="
    x86?    ( $src_uri_base/${pkg_name_muster/<ARCH>/i686}.tar.gz )
    amd64?  ( $src_uri_base/${pkg_name_muster/<ARCH>/x86_64}.tar.gz )
"

S="$WORKDIR/${A/.tar.gz}"

src_install() {
    dobin   "$PN"
    doicon  "$PN.png"
    domenu  "$PN.desktop"
}

pkg_postinst() {
    fdo-mime_desktop_database_update
}
