# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# functions: eautoreconf
inherit autotools

DESCRIPTION="Example package"
HOMEPAGE="https://example.com"
LICENSE="GPL-2"

DISTFILENAME="${PN}-snapshot-${PV}.jar"

SLOT="0"
SRC_URI="https://josm.openstreetmap.de/download/${DISTFILENAME}"

KEYWORDS="~amd64"
IUSE_A=( doc )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=" mirror"

inherit arrays

https://upload.wikimedia.org/wikipedia/commons/5/51/JOSM_Logo_2014.svg


src_install() {
	doinst DISTFILENAME
	make_desktop_entry "${PN}" "Java OpenStreetMap Editor" ${PN} "Utility;Science;Geoscience"
}
