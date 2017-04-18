# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN='github:fcambus'

inherit git-hosting
inherit cmake-utils

DESCRIPTION='Web log analyzer using probabilistic data structures'
LICENSE='BSD-2'

SLOT='0'

KEYWORDS='~amd64 ~arm ~arm64'

CDEPEND="
	dev-libs/geoip:0
	dev-libs/jansson:0
"
DEPEND="${CDEPEND}
	virtual/pkgconfig
"
RDEPEND="${CDEPEND}"

src_prepare() {
	default

	# https://github.com/fcambus/logswan/pull/12
	sed -r -e '/^add_definitions/ s,(-Werror|-pedantic),,g' -i -- CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DGEOIPDIR="$(pkg-config --variable=databasedir geoip)"
	)

	cmake-utils_src_configure
}
