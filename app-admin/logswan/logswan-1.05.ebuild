# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

GH_USER='fcambus'

inherit github cmake-utils toolchain-funcs

DESCRIPTION='Web log analyzer using probabilistic data structures'
LICENSE='BSD'

SLOT='0'

KEYWORDS='~amd64 ~arm ~x86'

CDEPEND="
	dev-libs/geoip:0
	dev-libs/jansson:0
"
DEPEND="${CDEPEND}
	virtual/pkgconfig
"
RDEPEND="${CDEPEND}"

src_configure() {
	local mycmakeargs=(
		"-DGEOIPDIR=$(tc-getPKG_CONFIG --variable=databasedir geoip)"
	)

	cmake-utils_src_configure
}
