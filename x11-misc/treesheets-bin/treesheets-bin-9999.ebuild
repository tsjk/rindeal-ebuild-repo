# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:aardappel"
GH_FETCH_TYPE=manual

inherit git-hosting
# functions: domenu, newicon
inherit eutils
inherit xdg

DESCRIPTION="Example package"
HOMEPAGE="http://strlen.com/treesheets/ ${GH_HOMEPAGE}"
LICENSE="ZLIB"

PN_NOBIN="${PN%%-bin}"
SLOT="0"
SRC_URI="http://strlen.com/treesheets/treesheets_linux64.tar.gz"

KEYWORDS="~amd64"
IUSE="doc examples"

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

RESTRICT="mirror test"

inherit arrays

S="${WORKDIR}/TS"

INST_DIR="/opt/${PN_NOBIN}"

src_prepare() {
	xdg_src_prepare

	sed -r -e "s|(Try)?Exec=|\1Exec=${EPREFIX}${INST_DIR}/|" \
		-i -- "${PN_NOBIN}.desktop" || die
}

src_install() {
	## NOTE: everything must reside in the same dir and with the same structure

	into "${INST_DIR}"

	exeinto "${INST_DIR}"
	doexe "${PN_NOBIN}"

	domenu "${PN_NOBIN}.desktop"

	newicon -s 16 images/icon16.png "${PN_NOBIN}"
	newicon -s 32 images/icon32.png "${PN_NOBIN}"

	insinto "${INST_DIR}"
	doins -r images

	insinto "${INST_DIR}"
	doins "readme.html"

	if use doc ; then
		insinto "${INST_DIR}"
		doins -r docs
	fi

	if use examples ; then
		docinto "${INST_DIR}"
		dodoc -r examples
	fi
}
