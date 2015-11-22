# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Tixati is a New and Powerful P2P System"
HOMEPAGE="http://www.tixati.com"

src_uri_base="http://www.tixati.com/download"
pkg_ext="tar.gz"

SRC_URI="
    x86?    ( $src_uri_base/${PN}-${PV}-1.x86_64.manualinstall.$pkg_ext )
    amd64?  ( $src_uri_base/${PN}-${PV}-1.i686.manualinstall.$pkg_ext )
"

if has amd64 $USE; then
    pkg_name="${PN}-${PV}-1.x86_64.manualinstall"
elif has x86 $USE; then
    pkg_name="${PN}-${PV}-1.i686.manualinstall"
fi

S="$WORKDIR/$pkg_name"

RESTRICT="mirror strip"

LICENSE="tixati"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
    dobin   "tixati"
    doicon  "tixati.png"
    domenu  "tixati.desktop"
}

pkg_postinst() {
    fdo-mime_desktop_database_update
    gnome2_icon_cache_update
}
