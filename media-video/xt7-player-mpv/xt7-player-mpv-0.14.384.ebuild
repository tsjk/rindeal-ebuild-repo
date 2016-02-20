# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Xt7-Player-mpv is a graphical interface to mpv, focused on usability"
HOMEPAGE="http://xt7-player.sourceforge.net/xt7forum/"
SRC_URI="https://github.com/kokoko3k/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"

RESTRICT="mirror"
SLOT="0"
KEYWORDS="~amd64"

IUSE="taglib global-hotkeys dvb youtube"

DEPEND="
	dev-lang/gambas:3[libxml,qt4,dbus,x11,net,curl]
	dev-qt/qtcore:4
	media-video/mpv:0
"
RDEPEND="${DEPEND}"

src_compile (){
	gbc3 --translate-errors --all --translate --public-control --public-module .
	gba3
}

src_install (){
	mv ${PN}*.gambas "${PN}.gambas" || true
	newbin "${PN}.gambas" "$PN"
	sed -r -i "s/${PN}.gambas/${PN}/" "${PN}.desktop"

	domenu "${PN}.desktop"
	doicon -s 48 "${PN}.png"
}
