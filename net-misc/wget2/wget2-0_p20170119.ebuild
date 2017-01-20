# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/rockdaboot"
GH_REF="dfc4b53eae942d6e1260ffbee5018612995959b7"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# functions: eautoreconf
inherit autotools

DESCRIPTION="Multithreaded metalink/file/website downloader/spider and library"
HOMEPAGE="https://savannah.gnu.org/projects/wget/ http://git.savannah.gnu.org/cgit/wget/wget2.git/ ${GH_HOMEPAGE}"
LICENSE="GPL-3+ LGPL-3+"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
    default

	rmdir gnulib || die
	ln -s "${EPREFIX}/usr/share/gnulib" || die

    eautoreconf
}

src_configure() {
    local myeconfargs=(

    )
    econf "${myeconfargs[@]}"
}
