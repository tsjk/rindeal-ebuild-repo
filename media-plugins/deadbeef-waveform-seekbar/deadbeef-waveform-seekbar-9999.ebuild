# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_URI="github/cboxdoerfer/ddb_waveform_seekbar"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit deadbeef-plugin

DESCRIPTION="Waveform Seekbar plugin for DeaDBeeF audio player"
LICENSE="GPL-2"

SLOT="0"

[[ "${PV}" != *9999* ]] && KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( +gtk2 +gtk3 )

CDEPEND_A=(
	"gtk2? ( x11-libs/gtk+:2 )"
	"gtk3? ( x11-libs/gtk+:3 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"|| ( gtk2 gtk3 )"
)

inherit arrays

src_prepare() {
	default

	sed -e '/^CFLAGS/ s| -O2||' -i -- Makefile || die
}

src_compile() {
	emake $(usev gtk2) $(usev gtk3)
}

src_install() {
	use gtk2 && ddb_plugin_doins gtk2/ddb_misc_waveform_GTK2.so
	use gtk3 && ddb_plugin_doins gtk3/ddb_misc_waveform_GTK3.so

	dodoc README.md
}
