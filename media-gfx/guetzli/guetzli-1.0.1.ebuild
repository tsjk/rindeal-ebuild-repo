# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:google"
GH_REF="v${PV}"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Perceptual JPEG encoder"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=(
	"media-libs/libpng"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	sed -r -e '/ALL_C(XX)?FLAGS[ +]*=/ s@(-O3|-g) @ @g' \
		-i -- "${PN}.make" || die
}

src_compile() {
	emake verbose=1 config=release "${PN}"
}

src_install() {
	dobin "bin/Release/${PN}"

	einstalldocs
}
