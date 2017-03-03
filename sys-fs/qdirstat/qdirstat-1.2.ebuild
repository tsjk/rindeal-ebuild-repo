# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/shundhammer"

inherit rindeal git-hosting qmake-utils xdg

DESCRIPTION="GUI app to show where your disk space has gone and to help you to clean it up"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="doc"

CDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

src_prepare() {
	eapply_user

	sed -e '/CONFIG.*=.* debug/d' -i -- src/src.pro || die

	sed -e '/SUBDIRS/ s| doc||' -i -- qdirstat.pro || die
}

src_configure() {
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${ED}" install

	einstalldocs
	dodoc DevHistory.md doc/cache-file-format.txt
}
