# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit versionator

DESCRIPTION="Example package"
HOMEPAGE="https://example.com"
LICENSE="GPL-2"

nomachine_slot="5.1"

SLOT="${nomachine_slot}"
SRC_URI="https://download.nomachine.com/download/${nomachine_slot}/Linux/nomachine_5.1.62_1_x86_64.tar.gz"

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

    eautoreconf
}

src_configure() {
    local myeconfargs=(

    )
    econf "${myeconfargs[@]}"
}
