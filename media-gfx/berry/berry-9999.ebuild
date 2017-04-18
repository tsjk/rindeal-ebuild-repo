# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:Aseman-Land:Berry"

inherit git-hosting
inherit qmake-utils
inherit xdg

DESCRIPTION="Simple, modern and light image viewer based on Qt5"
HOMEPAGE="http://aseman.co/en/products/berry/ ${HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE=""

CDEPEND_A=(
	"media-gfx/exiv2"
	"dev-qt/qtcore:5"
	"dev-qt/qtdbus:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtmultimedia:5"
	"dev-qt/qtnetwork:5"
	"dev-qt/qtprintsupport:5"
	"dev-qt/qtquickcontrols:5"
	"dev-qt/qtsql:5"
	"dev-qt/qtsvg:5"
	"dev-qt/qtwidgets:5"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	sed -e 's|\(QT \+=\)|\1 core |' -i -- asemantools/asemantools.pro || die

	sed -e '1 i\#include <QDataStream>' -i -- asemantools/qtsingleapplication/qtlocalpeer.cpp || die
}

src_configure() {
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
	doicon "files/icons/${PN}.png"

	sed -e "s|^Icon=.*|Icon=${PN}|" \
		-i -- "${ED}"/usr/share/applications/${PN^}.desktop || die
}
